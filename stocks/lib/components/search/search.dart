import 'package:flutter/material.dart';
import 'package:stocks/components/exchange_symbols/exchange_symbols.dart';
import 'package:stocks/components/space/space.dart';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/nav/nav.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/manager/symbols_manager.dart';
import 'package:stocks/manager/localizations_manager.dart';
import 'package:stocks/components/button/button_ wrapped.dart';

class GKSearchView extends StatefulWidget {
  void Function(Pair)? onSelected;
  GKSearchView(this.onSelected);
  @override
  _GKSearchViewState createState() => _GKSearchViewState(this.onSelected);
}

class _GKSearchViewState extends State<GKSearchView> {
  List<Pair> result = [];
  String searchStr = "";
  void Function(Pair)? _onSelected;
  _GKSearchViewState(this._onSelected);
  List<Widget> getExchangeLogo(Pair pair) {
    List<Widget> r = [];
    pair.exchangeSymbol.forEach((exchangeSymbol) {
      ExchangeModel? exchange =
          ExchangeManager.getExchangeModel(exchangeSymbol);
      if (exchange != null) {
        r.add(exchange.logo != null && exchange.logo!.length > 0
            ? Image.network(
                exchange.logo!,
                width: GNTheme().fontSizeType(FontSizeType.s),
                loadingBuilder: (context, o, s) {
                  return GNText("${exchange.name} ", color: exchange.mainColor,);
                },
                errorBuilder: (context, o, s) {
                  return GNText("${exchange.name} ", color: exchange.mainColor);
                },
              )
            : GNText("${exchange.name}", color: exchange.mainColor));
      }
    });
    return r;
  }

  List<Widget> getRow() {
    List<Widget> r = [];
    result.forEach((element) {
      r.add(GKWrappedButton(
        onPressed: () {
          this._onSelected!(element);
        },
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    heighlightText(searchStr.toLowerCase(),
                        element.token0.symbol.toLowerCase()),
                    GNText("/"),
                    heighlightText(searchStr.toLowerCase(),
                        element.token1.symbol.toLowerCase()),
                  ],
                ),
                ExchangeSymbols(element.exchangeSymbol)
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
        GNSpace(),
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
  void Function(Pair)? onSelected;
  Function(GKSearch)? onPressedCancel;
  GKSearch({
    this.onSelected,
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
          content: GKSearchView(this.onSelected),
          actions: <Widget>[
            TextButton(
                child: GNText(
                  'Cancel',
                  color: theme.fontColorType(FontColorType.bright),
                  isi18n: true,
                ),
                onPressed: () {
                  close();
                }),
          ],
        );
      },
    );
  }
}
