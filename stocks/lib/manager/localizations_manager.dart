import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../nav/nav.dart';
import '../tools/GNLog.dart';

class GNLocalizations {
  static Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GNLocalizationsDelegate.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate
  ];
  static Iterable<Locale> supportedLocales = [
    Locale('zh'),
    Locale('en'),
  ];

  static GNLocalizations? _instance;

  GNLocalizations._internal();

  Locale? locale;
  Localizations? localizations;
  factory GNLocalizations() {
    if (_instance == null) {
      _instance = GNLocalizations._internal();
    }
    return _instance!;
  }

  setLocale(Locale locale) {
    this.locale = locale;
  }

  static GNLocalizations of(BuildContext _context) {
    return Localizations.of(_context, GNLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'Token': 'Token',
    },
    'zh': {
      'Input here': '这儿',
      'Add tag': '添加标签',
      'empty!': '不能为空！',
      'There are multiple files in this folder. Are you sure to delete them?':
          '此文件夹包含了多个文件，确定要删除吗？',
      'warning': '提醒',
      'input file name': '文件名',
      'new note': '新建笔记',
      'change layout': '切换布局',
      'rename and edit mark': '重命名，编辑标记',
      'drag left and right': '左右拖动',
      'open directory': '打开一个目录',
      'input category name': '请输入类别名称',
      'Cancel': '取消',
      'OK': '确定',
      'show add category menu': '创建类别',
      'Powered by Flutter': '基于 Flutter',
      'Login': '登录',
      'Token': '代币',
    },
  };

  getStr(String str) {
    if (this.locale != null) {
      String? strTemp = _localizedValues[locale!.languageCode]?[str];
      if (strTemp == null) {
        if (locale!.languageCode != 'en') {
          GNLog.w('no Localizations ${locale!.languageCode}: "$str"');
        }
        return str;
      }
      return strTemp;
    }

    return str;
  }

  static String str(String str) {
    return GNLocalizations.of(Nav().context).getStr(str);
  }
}

class GNLocalizationsDelegate extends LocalizationsDelegate<GNLocalizations> {
  const GNLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<GNLocalizations> load(Locale locale) {
    GNLocalizations t = GNLocalizations();
    t.setLocale(locale);
    return SynchronousFuture<GNLocalizations>(t);
  }

  @override
  bool shouldReload(LocalizationsDelegate<GNLocalizations> old) {
    return false;
  }

  static const GNLocalizationsDelegate delegate = GNLocalizationsDelegate();
}
