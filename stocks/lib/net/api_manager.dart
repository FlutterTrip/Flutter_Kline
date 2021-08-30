import 'package:stocks/manager/exchange_manager.dart';

enum apiType { kline, baseUrl }

enum apiReqType { get, post, socket }

class APIManager {
  Map<ExchangeSymbol, Map<apiType, Map<apiReqType, String>>> apiMap = {
    ExchangeSymbol.BSC: {
      apiType.baseUrl: {
        apiReqType.socket: 'wss://stream.binance.com:9443',
        apiReqType.get: 'https://api.binance.com'
      },
      apiType.kline: {apiReqType.socket: '', apiReqType.get: '/api/v3/klines'}
    }
  };

  static APIManager? _instance;

  APIManager._();

  static instance() {
    if (_instance == null) {
      _instance = APIManager._();
    }
    return _instance;
  }

  String getSocketAPI(ExchangeSymbol symbol) {
    return this.apiMap[symbol]![apiType.baseUrl]![apiReqType.socket]!;
  }

  String getKlineSocketAPI(ExchangeSymbol symbol) {
    return this.getSocketAPI(symbol);
  }

  String getKlineGetAPI(ExchangeSymbol symbol) {
    String api = this.apiMap[symbol]![apiType.kline]![apiReqType.get]!;
    String base = this.apiMap[symbol]![apiType.baseUrl]![apiReqType.get]!;
    return "$base$api";
  }

  String getHqSocketApi(ExchangeSymbol symbol) {
    return this.getSocketAPI(symbol);
  }
}
