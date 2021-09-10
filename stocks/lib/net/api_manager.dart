import 'package:stocks/manager/exchange_manager.dart';

enum apiType { kline, baseUrl, symbols }

enum apiReqType { get, post, socket }

const Map BSCAUTH = {
  "key": "z3unZp6qVrNEsyOxNoAOWgi0TqMmzgvcr72qM2rgklm62nFs8yAo9lCg9LpqXjWU",
  "secret": "zsqLdu7s0lNiJKh7BNcXo8OEH1SMrC4LpdYCZ0VWUfiQwValTERUy8xfRzuLyWdO"
};
class APIManager {
  Map<ExchangeSymbol, Map<apiType, Map<apiReqType, String>>> apiMap = {
    ExchangeSymbol.BSC: {
      apiType.baseUrl: {
        apiReqType.socket: 'wss://stream2.binance.com:9443/ws',
        apiReqType.get: 'https://api2.binance.com'
      },
      apiType.kline: {apiReqType.socket: '', apiReqType.get: '/api/v3/klines'},
      apiType.symbols: {apiReqType.get: '/api/v3/exchangeInfo'}
    }
  };

  static APIManager? _instance;

  APIManager._();

  static APIManager instance() {
    if (_instance == null) {
      _instance = APIManager._();
    }
    return _instance!;
  }

  static String? getApi(ExchangeSymbol symbol, apiType type, {apiReqType? reqType = apiReqType.get}) {
    return APIManager.instance().apiMap[symbol]?[type]?[reqType];
  }
}
