import 'package:flutter/material.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/nav/nav.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/manager/symbols_manager.dart';
import 'package:stocks/manager/localizations_manager.dart';

class GKSearchView extends StatefulWidget {
  const GKSearchView({Key? key}) : super(key: key);

  @override
  _GKSearchViewState createState() => _GKSearchViewState();
}

class _GKSearchViewState extends State<GKSearchView> {
  List<Pair> result = [];
  String searchStr = "";
  List<Widget> getRow() {
    List<Widget> r = [];
    result.forEach((element) {
      r.add(Container(
        height: 30,
        child: Row(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    heighlightText(searchStr.toLowerCase(),
                        element.token0.symbol.toLowerCase()),
                    GNText("/"),
                    heighlightText(searchStr.toLowerCase(),
                        element.token1.symbol.toLowerCase()),
                  ],
                )
              ],
            )
          ],
        ),
      ));
    });
    return r;
  }

  heighlightText(String str, String sourceStr) {
    List<String> sa = sourceStr.split(str);
    List<TextSpan> r = [];
    int index = 0;
    sa.forEach((element) {
      r.add(TextSpan(
          text: element.toUpperCase(),
          style: TextStyle(
              color: GNTheme().fontColorType(FontColorType.content))));
      if (index != sa.length - 1) {
        r.add(TextSpan(
            text: str.toUpperCase(),
            style: TextStyle(
                color: GNTheme().fontColorType(FontColorType.bright))));
      }
      index++;
    });
    return RichText(
        text: TextSpan(
            children: r,
            style: TextStyle(
              fontSize: GNTheme().fontSizeType(FontSizeType.md),
            )));
    // print(sa);
    // print(str);
    // print(sourceStr);
  }

  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme();
    return Column(
      children: [
        Container(
            height: 30,
            child: TextField(
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.bottom,
              onChanged: (value) {
                searchStr = value;
                if (value == "") {
                  setState(() {
                    result = [];
                  });
                } else {
                  SymbolsManager.search(value, (List<Pair> r) {
                    if (searchStr != "") {
                      setState(() {
                        result = r;
                      });
                    }
                  });
                }
              },
              cursorColor: theme.fontColorType(FontColorType.bright),
              style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: theme.fontSizeType(FontSizeType.md),
                  color: theme.fontColorType(FontColorType.title)),
              decoration: InputDecoration(
                  alignLabelWithHint: true,
                  hoverColor: theme.bGColorType(BGColorType.highlight),
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: theme.fontSizeType(FontSizeType.md),
                      color: theme.fontColorType(FontColorType.bright)),
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                  hintText: GNLocalizations.str("Input here")),
            )),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: getRow(),
          ),
        ))
      ],
    );
  }
}

class GKSearch {
  Function(GKSearch)? onPressedOK;
  Function(GKSearch)? onPressedCancel;
  GKSearch({
    this.onPressedOK,
    this.onPressedCancel,
  });
  close() {
    Nav().pop();
  }

  show() {
    GNTheme theme = GNTheme();
    showDialog<void>(
      context: Nav().context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          title: GNText(
            "Search",
            fontSize: theme.fontSizeType(FontSizeType.lg),
            color: theme.fontColorType(FontColorType.bright),
          ),
          content: GKSearchView(),
          actions: <Widget>[
            TextButton(
                child: GNText(
                  'Cancel',
                  color: theme.fontColorType(FontColorType.bright),
                  isi18n: true,
                ),
                onPressed: () {
                  close();
                  if (this.onPressedOK != null) this.onPressedOK!(this);
                }),
          ],
        );
      },
    );
  }
}
