import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/theme_manager.dart';

class MenuView extends StatefulWidget {
  @override
  _MenuViewState createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
 
  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme(context);
    return Container(
        margin: EdgeInsets.only(top: 35, left: 8, right: 8),
        width: 150,
        color: Colors.transparent,
        );
  }
}

