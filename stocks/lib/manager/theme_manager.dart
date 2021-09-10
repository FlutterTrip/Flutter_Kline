import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

enum FontSizeType { xs, s, md, xmd, lg, xlg }

enum FontColorType {
  content,
  title,
  subTitle,
  bright,
  highlight,
  dark,
  gray,
  error,
  warning
}

enum BGColorType {
  background,
  content,
  toast,
  normalBtn,
  highlight,
  bright,
  dark,
  gray,
  error,
  warning
}

enum ZDColorType {
  up, down, normal
}

enum FontFamilyType { content, title, subTitle, other }

class GNThemeManager {
  static Map themeData = {
    "default": {
      'FontSizeType': {
        'xs': 10.0,
        's': 12.0,
        'md': 14.0,
        'xmd': 18.0,
        'lg': 24.0,
        'xlg': 36.0
      },
      'FontColorType': {
        'content': 0xFF555555,
        'title': 0xFF555555,
        'subTitle': 0xFF868686,
        'bright': 0xFF21BF73,
        'dark': 0xFF1C262C,
        'gray': 0xFF868686,
        'highlight': 0xFFF5FDFA,
        'error': 0xFFFD5E53,
        'warning': 0xFFffc478,
      },
      'BGColorType': {
        'background': 0xFFFFFFFF,
        'content': 0xFFFFFFFF,
        'toast': 0xFFF5FDFA,
        'normalBtn': 0xFFFFFFFF,
        'bright': 0xFFB0EACD,
        'dark': 0x00FFFFFF,
        'gray': 0xFFF7FBFC,
        'highlight': 0xFFF5FDFA,
        'error': 0xFFF5FDFA,
        'warning': 0xFFF5FDFA,
      },
      'FontFamilyType': {
        'content': '',
        'title': '',
        'subTitle': '',
        'other': ''
      }
    },
    "dark": {
      'FontSizeType': {
        'xs': 10.0,
        's': 12.0,
        'md': 14.0,
        'xmd': 18.0,
        'lg': 24.0,
        'xlg': 36.0
      },
      'FontColorType': {
        'content': 0xFFe7e7de,
        'title': 0xFFe7e7de,
        'subTitle': 0xFF769FCD,
        'bright': 0xFF008891,
        'dark': 0xFF1C262C,
        'gray': 0xFFF7FBFC,
        'highlight': 0xFF00587a,
        'error': 0xFFFD5E53,
        'warning': 0xFFffc478,
      },
      'BGColorType': {
        'background': 0xFF0f3057,
        'content': 0xFF0f3057,
        'toast': 0xFF00587a,
        'normalBtn': 0xFFECB390,
        'bright': 0xFFe7e7de,
        'dark': 0xFF0f3057,
        'gray': 0xFFF7FBFC,
        'highlight': 0xFF00587a,
        'error': 0xFF00587a,
        'warning': 0xFF00587a,
      },
      'FontFamilyType': {
        'content': '',
        'title': '',
        'subTitle': '',
        'other': ''
      }
    }
  };

  static bool isAuto = true;
  static Brightness systemStatus = Brightness.light;
  static Brightness lastSystemStatus = Brightness.light;
  static String nowTheme = 'default';
  static String lastTheme = 'default';

  static changeTheme(String themeName) {
    Map theme = themeData[themeName];
    // TODO: 扩充自定义皮肤
    if (theme != null && theme['name'] != nowTheme) {
      GNTheme().setThemeData(theme);
    }
  }

  static changeBackgroundAlpha(int alpha) {
    GNTheme().setBackgroundAlpha(alpha);
  }

  static autoChangeDarkOrLight(Brightness brightness, [BuildContext? context]) {
    // MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness;
    Brightness nowSystemStatus = brightness;
    if (!isAuto || nowSystemStatus == systemStatus) return;
    String themeName = nowSystemStatus == Brightness.light ? 'default' : 'dark';
    print('自动切换皮肤 ${themeName}');
    changeTheme(themeName);
    lastSystemStatus = systemStatus;
    systemStatus = nowSystemStatus;
  }

  static GNThemeManager? _m;
  factory GNThemeManager([BuildContext? context]) {
    if (_m == null) {
      _m = GNThemeManager._internal();
    }
    if (context != null) {
      Brightness nowSystemStatus = MediaQuery.of(context).platformBrightness;
      nowTheme = nowSystemStatus == Brightness.light ? 'default' : 'dark';
      lastTheme = nowTheme;
      GNTheme().sourceThemeData = themeData[nowTheme];
    }
    return _m!;
  }
  GNThemeManager._internal();
}

class GNTheme with ChangeNotifier {
  static GNTheme? _m;
  List tagColors = [
    0xFFffa41b,
    0xFF000839,
    0xFF005082,
    0xFF00a8cc,
    0xFFeb4559,
    0xFFf78259,
    0xFFaeefec,
    0xFFf8eeee,
    0xFFf4eeff,
    0xFFdcd6f7,
    0xFF21bf73,
    0xFF4f3961,
    0xFFf35588
  ];
  List markColors = [
    0xFFffa41b,
    0xFF000839,
    0xFF005082,
    0xFF00a8cc,
    0xFFeb4559,
    0xFFf78259,
    0xFFaeefec,
    0xFFf8eeee,
    0xFFf4eeff,
    0xFFdcd6f7,
    0xFF21bf73,
    0xFF4f3961,
    0xFFf35588
  ];

  Map<ZDColorType, Color> zdColor = {
    ZDColorType.up: Colors.green,
    ZDColorType.down: Colors.red,
    ZDColorType.normal: Colors.grey
  };

  Map sourceThemeData = GNThemeManager.themeData["default"];
  // TODO: useless
  int backgroundAlpha = 0;
  factory GNTheme([BuildContext? context]) {
    if (_m == null) {
      _m = GNTheme._internal();
    }
    if (context == null) {
      return _m!;
    }
    return Provider.of<GNTheme>(context);
  }
  GNTheme._internal();

  setThemeData(Map data) {
    this.sourceThemeData = data;
    notifyListeners();
  }

  setBackgroundAlpha(int alpha) {
    this.backgroundAlpha = alpha;
    notifyListeners();
  }

  Color getZDColor(ZDColorType type) {
      return zdColor[type]!;
  }

  Color getTagsColor() {
    int index = Random().nextInt(tagColors.length - 1);
    return Color(tagColors[index]);
  }

  String fontFamilyType(FontFamilyType type) {
    var sourceMap = sourceThemeData['FontFamilyType'];
    switch (type) {
      case FontFamilyType.content:
        return sourceMap['content'];
      case FontFamilyType.title:
        return sourceMap['title'];
      case FontFamilyType.subTitle:
        return sourceMap['subTitle'];
      case FontFamilyType.other:
        return sourceMap['other'];
      default:
        return sourceMap['content'];
    }
  }

  double fontSizeType(FontSizeType type) {
    var sourceMap = sourceThemeData['FontSizeType'];
    double num;
    switch (type) {
      case FontSizeType.xs:
        num = sourceMap['xs'];
        break;
      case FontSizeType.s:
        num = sourceMap['s'];
        break;
      case FontSizeType.md:
        num = sourceMap['md'];
        break;
      case FontSizeType.xmd:
        num = sourceMap['xmd'];
        break;
      case FontSizeType.lg:
        num = sourceMap['lg'];
        break;
      case FontSizeType.xlg:
        num = sourceMap['xlg'];
        break;
      default:
        num = sourceMap['md'];
        break;
    }
    return num;
  }

  Color fontColorType(FontColorType type) {
    var sourceMap = sourceThemeData['FontColorType'];
    var colorNum;
    switch (type) {
      case FontColorType.content:
        colorNum = sourceMap['content'];
        break;
      case FontColorType.title:
        colorNum = sourceMap['title'];
        break;
      case FontColorType.subTitle:
        colorNum = sourceMap['subTitle'];
        break;
      case FontColorType.bright:
        colorNum = sourceMap['bright'];
        break;
      case FontColorType.dark:
        colorNum = sourceMap['dark'];
        break;
      case FontColorType.gray:
        colorNum = sourceMap['gray'];
        break;
      case FontColorType.highlight:
        colorNum = sourceMap['highlight'];
        break;
      case FontColorType.error:
        colorNum = sourceMap['error'];
        break;
      case FontColorType.warning:
        colorNum = sourceMap['warning'];
        break;
      default:
        colorNum = sourceMap['content'];
        break;
    }
    return Color(colorNum);
  }

  Color bGColorType(BGColorType type) {
    var sourceMap = sourceThemeData['BGColorType'];
    var colorNum;
    switch (type) {
      case BGColorType.background:
        colorNum = sourceMap['background'];
        break;
      case BGColorType.content:
        colorNum = sourceMap['content'];
        break;
      case BGColorType.toast:
        colorNum = sourceMap['toast'];
        break;
      case BGColorType.normalBtn:
        colorNum = sourceMap['normalBtn'];
        break;
      case BGColorType.bright:
        colorNum = sourceMap['bright'];
        break;
      case BGColorType.dark:
        colorNum = sourceMap['dark'];
        break;
      case BGColorType.gray:
        colorNum = sourceMap['gray'];
        break;
      case BGColorType.highlight:
        colorNum = sourceMap['highlight'];
        break;
      case BGColorType.error:
        colorNum = sourceMap['error'];
        break;
      case BGColorType.warning:
        colorNum = sourceMap['warning'];
        break;
      default:
        colorNum = sourceMap['content'];
        break;
    }
    return Color(colorNum);
  }
}
