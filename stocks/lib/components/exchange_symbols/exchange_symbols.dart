import 'package:flutter/material.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/manager/theme_manager.dart';

class ExchangeSymbols extends StatelessWidget {
  final List<ExchangeSymbol> exchangeSymbol;
  const ExchangeSymbols(this.exchangeSymbol, {Key? key}) : super(key: key);
  List<Widget> getExchangeLogo() {
    List<Widget> r = [];
    exchangeSymbol.forEach((element) {
      ExchangeModel? exchange = ExchangeManager.getExchangeModel(element);
      r.add(getImg(exchange));
    });
    return r;
  }

  Widget getImg(ExchangeModel? exchange) {
    if (exchange != null) {
      GNText text = GNText(
        "${exchange.name} ",
        color: exchange.mainColor,
      );
      return exchange.logo != null && exchange.logo!.length > 0
          ? Image.network(
              exchange.logo!,
              width: GNTheme().fontSizeType(FontSizeType.s),
              loadingBuilder: (context, o, s) {
                return text;
              },
              errorBuilder: (context, o, s) {
                return text;
              },
            )
          : text;
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return exchangeSymbol.length > 0
        ? Container(
            child: exchangeSymbol.length == 1
                ? getImg(ExchangeManager.getExchangeModel(exchangeSymbol[0]))
                : Row(children: getExchangeLogo()))
        : Container();
  }
}
