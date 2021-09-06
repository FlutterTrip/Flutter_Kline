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
  String apiKey = '';
  ExchangeModel(this.symbol, this.name, this.isDefi, this.desc, this.webUrl,
      this.apiKey, this.index,
      {this.currency});
}

class ExchangeManager {
  static Map<ExchangeSymbol,ExchangeModel> exchanges = {
    ExchangeSymbol.BSC: ExchangeModel(ExchangeSymbol.BSC, '币安', false, '币安---',
        'https://www.binance.com/', '', 0,
        currency: Currency('Bnb', 'Bnb'))
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
