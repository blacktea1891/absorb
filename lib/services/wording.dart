import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Whether to use classic player vocabulary ("Play", "Now Playing", "Finished")
/// instead of the Absorb-themed vocabulary ("Absorb", "Absorbing", "Fully
/// Absorbed"). Lives at app level so any widget rebuilds when it flips.
final ValueNotifier<bool> classicWordingNotifier = ValueNotifier(false);

/// Returns either the Absorb-branded localization or a plain-English
/// equivalent depending on [classicWordingNotifier]. Only the English
/// surface is overridden — translated locales keep their existing strings.
class Wording {
  final AppLocalizations _l;
  final bool classic;
  const Wording._(this._l, this.classic);

  static Wording of(BuildContext context) =>
      Wording._(AppLocalizations.of(context)!, classicWordingNotifier.value);

  /// For code that already holds the strings but has no context to hand -
  /// helpers called from a build method's callee, mostly.
  static Wording from(AppLocalizations l) =>
      Wording._(l, classicWordingNotifier.value);

  // ── Card primary action ──
  String get absorb => classic ? _l.classicPlay : _l.absorb;
  String get absorbing => classic ? _l.classicPlaying : _l.absorbing;
  String get absorbAgain => classic ? _l.classicPlayAgain : _l.absorbAgain;
  String get fullyAbsorbed => classic ? _l.classicFinished : _l.fullyAbsorbed;
  String get fullyAbsorbAction => classic ? _l.classicMarkFinished : _l.fullyAbsorbAction;

  // ── Now Playing list ──
  String get addToAbsorbing => classic ? _l.classicAddToNowPlaying : _l.addToAbsorbing;
  String get absorbNext => classic ? _l.classicPlayNext : _l.absorbNext;
  String get absorbLast => classic ? _l.classicPlayLast : _l.absorbLast;
  String get absorbNextAdded => classic ? _l.classicUpNextInNowPlaying : _l.absorbNextAdded;
  String get removeFromAbsorbing => classic ? _l.classicRemoveFromNowPlaying : _l.removeFromAbsorbing;
  String get addedToAbsorbing => classic ? _l.classicAddedToNowPlaying : _l.addedToAbsorbing;
  String get removedFromAbsorbing => classic ? _l.classicRemovedFromNowPlaying : _l.removedFromAbsorbing;

  String episodeListAddedToAbsorbing(String title) =>
      classic ? _l.classicAddedTitleToNowPlaying(title) : _l.episodeListAddedToAbsorbing(title);
  String playlistDetailAddedToAbsorbing(String title) =>
      classic ? _l.classicAddedTitleToNowPlaying(title) : _l.playlistDetailAddedToAbsorbing(title);
  String collectionDetailAddedToAbsorbing(String title) =>
      classic ? _l.classicAddedTitleToNowPlaying(title) : _l.collectionDetailAddedToAbsorbing(title);
  String sectionDetailAddedToAbsorbing(String title) =>
      classic ? _l.classicAddedTitleToNowPlaying(title) : _l.sectionDetailAddedToAbsorbing(title);

  // ── Navigation / sections ──
  String get absorbingTitle => classic ? _l.classicNowPlaying : _l.absorbingTitle;
  String get appShellAbsorbingTab => classic ? _l.classicNowPlaying : _l.appShellAbsorbingTab;
  String get startScreenAbsorb => classic ? _l.classicNowPlaying : _l.startScreenAbsorb;
  String get sectionAbsorbingCards => classic ? _l.classicPlayerCards : _l.sectionAbsorbingCards;

  // ── Unified Absorbing page setting ──
  String get mergeLibraries =>
      classic ? _l.classicUnifiedNowPlayingPage : _l.mergeLibraries;
  String get mergeLibrariesInfoTitle =>
      classic ? _l.classicUnifiedNowPlayingPageTitle : _l.mergeLibrariesInfoTitle;
  String get mergeLibrariesInfoContent => classic
      ? _l.classicUnifiedNowPlayingDescription
      : _l.mergeLibrariesInfoContent;
  String get mergeLibrariesOnSubtitle => classic
      ? _l.classicNowPlayingAllLibraries
      : _l.mergeLibrariesOnSubtitle;
  String get mergeLibrariesOffSubtitle => classic
      ? _l.classicNowPlayingCurrentLibrary
      : _l.mergeLibrariesOffSubtitle;

  // ── Empty / placeholder ──
  String get absorbingNothingAbsorbingYet =>
      classic ? _l.classicNothingPlaying : _l.absorbingNothingAbsorbingYet;

  // ── Mark-finished dialogs ──
  String get markAsFullyAbsorbedQuestion =>
      classic ? _l.classicMarkAsFinished : _l.markAsFullyAbsorbedQuestion;
  String get fullyAbsorbSeries =>
      classic ? _l.classicMarkSeriesFinished : _l.fullyAbsorbSeries;

  // ── Settings labels ──
  String get whenAbsorbed => classic ? _l.classicWhenFinished : _l.whenAbsorbed;
  String get whenAbsorbedInfoTitle => classic ? _l.classicWhenFinishedTitle : _l.whenAbsorbedInfoTitle;
  String get whenAbsorbedSubtitle => classic
      ? _l.classicWhenFinishedDescription
      : _l.whenAbsorbedSubtitle;
  String get deleteAbsorbedDownloads =>
      classic ? _l.classicDeleteFinishedDownloads : _l.deleteAbsorbedDownloads;
  String get deleteAbsorbedDownloadsInfoTitle =>
      classic ? _l.classicDeleteFinishedDownloadsTitle : _l.deleteAbsorbedDownloadsInfoTitle;

  // ── Login ──
  String get loginTagline => classic ? _l.classicStartListening : _l.loginTagline;

  // ── Tips ──
  String get tipsSheetQuickAddAbsorbingTitle =>
      classic ? _l.classicQuickAddToNowPlaying : _l.tipsSheetQuickAddAbsorbingTitle;
  String get tipsSheetQuickAddAbsorbingDesc => classic
      ? _l.classicQuickAddDescription
      : _l.tipsSheetQuickAddAbsorbingDesc;

  // ── Queue mode info popup ──
  String get queueModeInfoManualDesc => classic
      ? _l.classicQueueModeManualDescription
      : _l.queueModeInfoManualDesc;
}
