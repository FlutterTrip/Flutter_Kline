import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/pages/page_action.dart';

class MenuView extends StatefulWidget {
  final int defaultSel;
  MenuView(this.defaultSel);
  @override
  _MenuViewState createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  
  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme(context);
    return Container(
        margin: EdgeInsets.only(top: 35, left: 8, right: 8),
        width: 50,
        color: Colors.transparent,
        child: Column(
          children: [
            IconButton(onPressed: (){
              GNPagesAction().callAction(PageName.main, FuncName.clickMenu, data: [0]);
            }, icon: Icon(Icons.list), color: GNTheme().fontColorType(FontColorType.bright),),
            IconButton(
            onPressed: () {
              GNPagesAction()
                  .callAction(PageName.main, FuncName.clickMenu, data: [1]);
            },
            icon: Icon(Icons.male),
            color: GNTheme().fontColorType(FontColorType.bright),
          )
          ],
        ),
        );
  }
}

