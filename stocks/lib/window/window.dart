import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../manager/localizations_manager.dart';
import '../manager/theme_manager.dart';
import '../nav/nav.dart';
import '../pages/main_view/main_view.dart';

class Window extends StatefulWidget {
  Window({Key? key}) : super(key: key);
  @override
  _Window createState() => _Window();
}

class _Window extends State<Window> {
  final Nav nav = Nav();
  Widget? zeroPage;
  @override
  void initState() {
    // init managers
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = ThemeData(
        textSelectionTheme: TextSelectionThemeData(
            selectionColor: GNTheme().fontColorType(FontColorType.highlight)),
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        buttonTheme: ButtonThemeData(
            minWidth: 0,
            height: 0,
            padding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0))));
    ThemeData darkThemeData = ThemeData(
        textSelectionTheme: TextSelectionThemeData(
            selectionColor: GNTheme().fontColorType(FontColorType.highlight)),
        backgroundColor: Colors.transparent,
        brightness: Brightness.dark,
        buttonTheme: ButtonThemeData(
            minWidth: 0,
            height: 0,
            padding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0))));
    nav.setZeroPage(MainPage());
    // nav.setZeroPage(Container(width: 300, height: 300, color: Colors.blue.withAlpha(0)));
    return ChangeNotifierProvider(
      create: (_) => GNTheme(),
      child: MaterialApp(
        theme: themeData,
        darkTheme: darkThemeData,
        title: 'Stocks',
        home: Scaffold(
          body: nav,
          backgroundColor: Colors.transparent,
        ),
        localizationsDelegates: GNLocalizations.localizationsDelegates,
        supportedLocales: GNLocalizations.supportedLocales,
      ),
    );
  }
}
