import AVFoundation
import Flutter
import Foundation
import MediaPlayer
import UIKit

/// Handles the cross-book audio transition when queue mode advances on iOS.
///
/// AVQueuePlayer auto-advance can leave the player rate at >0 with currentTime
/// advancing but no audio reaching the output route when the screen is locked.
/// This class forces the engine to restart on its own AVQueuePlayer (the one
/// just_audio created) by pausing and re-applying the rate, and updates the
/// lock screen Now Playing info from native code in the same moment so iOS
/// keeps showing controls during the swap.
final class IOSQueueAdvancer: NSObject {
  static let shared = IOSQueueAdvancer()

  static var logSink: ((String) -> Void)?

  private let queue = DispatchQueue(label: "com.barnabas.absorb.queueadvancer")

  private weak var _justAudioPlayer: AVQueuePlayer?
  private var _justAudioPlayerId: String?

  private var _nextTitle: String = ""
  private var _nextArtist: String = ""
  private var _nextDurationS: Double = 0
  private var _nextCoverPath: String?

  private override init() {
    super.init()
    NotificationCenter.default.addObserver(
      forName: Notification.Name("AbsorbJustAudioPlayerReady"),
      object: nil,
      queue: .main
    ) { [weak self] note in
      guard let player = note.userInfo?["player"] as? AVQueuePlayer else { return }
      let playerId = note.userInfo?["playerId"] as? String
      self?.queue.async {
        self?._justAudioPlayer = player
        self?._justAudioPlayerId = playerId
        self?.emit("[QueueAdvancer] captured just_audio player id=\(playerId ?? "?")")
      }
    }
    NotificationCenter.default.addObserver(
      forName: Notification.Name("AbsorbJustAudioPlayerReleased"),
      object: nil,
      queue: .main
    ) { [weak self] note in
      let playerId = note.userInfo?["playerId"] as? String
      self?.queue.async {
        if self?._justAudioPlayerId == playerId {
          self?._justAudioPlayer = nil
          self?._justAudioPlayerId = nil
          self?.emit("[QueueAdvancer] released just_audio player id=\(playerId ?? "?")")
        }
      }
    }
  }

  func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "com.absorb.queue_advancer",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    emit("[QueueAdvancer] channel registered")
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "prepareNext":
      let title = (args?["title"] as? String) ?? ""
      let artist = (args?["artist"] as? String) ?? ""
      let duration = (args?["durationS"] as? Double) ?? 0
      let coverPath = args?["coverPath"] as? String
      queue.async { [weak self] in
        self?._nextTitle = title
        self?._nextArtist = artist
        self?._nextDurationS = duration
        self?._nextCoverPath = coverPath
        self?.emit("[QueueAdvancer] prepared metadata for \(title)")
      }
      result(true)

    case "commitAdvance":
      let speed = (args?["speed"] as? Double) ?? 1.0
      commitAdvance(speed: speed, completion: { ok in result(ok) })

    case "clear":
      queue.async { [weak self] in
        self?._nextTitle = ""
        self?._nextArtist = ""
        self?._nextDurationS = 0
        self?._nextCoverPath = nil
      }
      result(true)

    case "isReady":
      result(_justAudioPlayer != nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func commitAdvance(speed: Double, completion: @escaping (Bool) -> Void) {
    queue.async { [weak self] in
      guard let self = self else { completion(false); return }
      self.activateSession()
      self.publishNowPlaying(rate: speed)
      guard let player = self._justAudioPlayer else {
        self.emit("[QueueAdvancer] commitAdvance: no just_audio player ref")
        completion(false)
        return
      }
      let target = Float(speed > 0 ? speed : 1.0)
      DispatchQueue.main.async {
        // Force the engine to re-emit audio: pause, then play and re-apply
        // the rate explicitly. This is what manual pause+play does for users.
        player.pause()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
          player.play()
          player.rate = target
          self.queue.async {
            self.emit("[QueueAdvancer] commitAdvance done rate=\(player.rate) for \(self._nextTitle)")
            // Re-publish Now Playing once the engine settles so the lock
            // screen shows the correct playing state and elapsed time.
            self.publishNowPlaying(rate: Double(target))
            completion(true)
          }
        }
      }
    }
  }

  private func activateSession() {
    let session = AVAudioSession.sharedInstance()
    do {
      if session.category != .playback {
        try session.setCategory(.playback, mode: .spokenAudio, policy: .longFormAudio)
      }
      try session.setActive(true)
    } catch {
      emit("[QueueAdvancer] session activate failed: \(error.localizedDescription)")
    }
  }

  private func publishNowPlaying(rate: Double) {
    let title = _nextTitle
    let artist = _nextArtist
    let duration = _nextDurationS
    let coverPath = _nextCoverPath
    guard !title.isEmpty else { return }
    var info: [String: Any] = [
      MPMediaItemPropertyTitle: title,
      MPMediaItemPropertyArtist: artist,
      MPNowPlayingInfoPropertyPlaybackRate: rate,
      MPNowPlayingInfoPropertyElapsedPlaybackTime: 0.0,
      MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue,
    ]
    if duration > 0 {
      info[MPMediaItemPropertyPlaybackDuration] = duration
    }
    if let coverPath = coverPath, let img = UIImage(contentsOfFile: coverPath) {
      let artwork = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
      info[MPMediaItemPropertyArtwork] = artwork
    }
    DispatchQueue.main.async {
      MPNowPlayingInfoCenter.default().nowPlayingInfo = info
      MPNowPlayingInfoCenter.default().playbackState = rate > 0 ? .playing : .paused
    }
  }

  private func emit(_ line: String) {
    NSLog("%@", line)
    Self.logSink?(line)
  }
}
