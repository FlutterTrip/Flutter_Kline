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
    },
    ExchangeSymbol.HB: {
      apiType.baseUrl: {
        apiReqType.socket: 'wss://api-aws.huobi.pro/ws',
        apiReqType.get: 'https://api.huobi.pro'
      },
      apiType.symbols: {apiReqType.get: '/v1/common/symbols'},
      apiType.kline: {apiReqType.get: '/market/history/kline'}
    },
    ExchangeSymbol.OK: {
      apiType.baseUrl: {
        apiReqType.socket: 'wss://ws.okex.com:8443/ws/v5/public',
        apiReqType.get: 'https://aws.okex.com'
      },
      apiType.symbols: {apiReqType.get: '/api/v5/public/instruments?instType=SPOT'},
      apiType.kline: {apiReqType.get: '/api/v5/market/candles'}
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

  static String? getApi(ExchangeSymbol symbol, apiType type,
      {apiReqType? reqType = apiReqType.get}) {
    return APIManager.instance().apiMap[symbol]?[type]?[reqType];
  }
}
