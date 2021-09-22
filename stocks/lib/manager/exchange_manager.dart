import 'package:flutter/material.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/models/tokenModel.dart';

enum ExchangeSymbol {
  BSC,
  HB,
  OK,
}

class ExchangeModel {
  ExchangeSymbol symbol = ExchangeSymbol.BSC;
  Currency? currency;
  String name = '--';
  bool isDefi = false;
  String desc = '--';
  String webUrl = '--';
  int index = 0;
  String? logo = "";
  String apiKey = '';
  Color? mainColor = GNTheme().fontColorType(FontColorType.content);
  ExchangeModel(this.symbol, this.name, this.isDefi, this.desc, this.webUrl,
      this.apiKey, this.index,
      {this.currency, this.logo, this.mainColor});
}

class ExchangeManager {
  static Map<ExchangeSymbol, ExchangeModel> exchanges = {
    ExchangeSymbol.BSC: ExchangeModel(ExchangeSymbol.BSC, 'Binance', false, '币安交易所',
        'https://www.binance.com/', '', 0,
        currency: Currency('Bnb', 'Bnb'),
        logo: "https://bin.bnbstatic.com/static/images/common/favicon.ico",
        mainColor: Colors.orange),
    ExchangeSymbol.HB: ExchangeModel(ExchangeSymbol.HB, 'Huobi', false, '火币交易所',
        'https://www.huobi.com/', '', 0,
        currency: Currency('HB', 'HB'),
        logo: "https://www.huobi.com/favicon.ico",
        mainColor: Colors.blue),
        ExchangeSymbol.OK: ExchangeModel(ExchangeSymbol.OK, 'OKEX', false, '欧易交易所',
        'https://www.okex.com/', '', 0,
        currency: Currency('OKB', 'OKB'),
        logo: "https://www.okex.com/favicon.ico",
        mainColor: Colors.lightBlue)
  };

  List<ExchangeSymbol> nowSelecteds = [ExchangeSymbol.BSC];

  static ExchangeManager? _instance;

  ExchangeManager._();

  static ExchangeManager instance() {
    if (_instance == null) {
      _instance = ExchangeManager._();
    }
    return _instance!;
  }

  static ExchangeModel? getExchangeModel(ExchangeSymbol symbol) {
    return ExchangeManager.exchanges[symbol];
  }
}
