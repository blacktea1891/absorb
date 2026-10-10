import 'package:flutter_test/flutter_test.dart';

import '../lib/l10n/app_localizations_en.dart';
import '../lib/l10n/app_localizations_zh.dart';
import '../lib/services/wording.dart';

void main() {
  tearDown(() => classicWordingNotifier.value = false);

  test('Classic vocabulary follows the selected locale', () {
    classicWordingNotifier.value = true;
    final zh = Wording.from(AppLocalizationsZh());
    final en = Wording.from(AppLocalizationsEn());

    expect(zh.absorb, '播放');
    expect(zh.absorbing, '正在播放…');
    expect(zh.absorbNext, '下一项播放');
    expect(zh.addToAbsorbing, '加入播放队列');
    expect(zh.episodeListAddedToAbsorbing('测试书籍'),
        '已将“测试书籍”加入播放队列');
    expect(zh.queueModeInfoManualDesc, contains('播放队列'));

    expect(en.absorb, 'Play');
    expect(en.absorbNext, 'Play Next');
    expect(en.episodeListAddedToAbsorbing('Example'),
        'Added "Example" to Now Playing');
  });

  test('Themed Chinese wording is preserved when classic mode is off', () {
    classicWordingNotifier.value = false;
    final zh = Wording.from(AppLocalizationsZh());

    expect(zh.absorbNext, '接着听');
    expect(zh.episodeListAddedToAbsorbing('测试书籍'),
        '已将“测试书籍”添加到播放队列');
  });
}
