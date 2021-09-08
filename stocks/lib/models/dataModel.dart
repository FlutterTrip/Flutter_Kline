import 'package:stocks/manager/exchange_manager.dart';

import 'tokenModel.dart';

// {
//   "e": "24hrTicker",  // 事件类型
//   "E": 123456789,     // 事件时间
//   "s": "BNBBTC",      // 交易对
//   "p": "0.0015",      // 24小时价格变化
//   "P": "250.00",      // 24小时价格变化(百分比)
//   "w": "0.0018",      // 平均价格
//   "x": "0.0009",      // 整整24小时之前，向前数的最后一次成交价格
//   "c": "0.0025",      // 最新成交价格
//   "Q": "10",          // 最新成交交易的成交量
//   "b": "0.0024",      // 目前最高买单价
//   "B": "10",          // 目前最高买单价的挂单量
//   "a": "0.0026",      // 目前最低卖单价
//   "A": "100",         // 目前最低卖单价的挂单量
//   "o": "0.0010",      // 整整24小时前，向后数的第一次成交价格
//   "h": "0.0025",      // 24小时内最高成交价
//   "l": "0.0010",      // 24小时内最低成交价
//   "v": "10000",       // 24小时内成交量
//   "q": "18",          // 24小时内成交额
//   "O": 0,             // 统计开始时间
//   "C": 86400000,      // 统计结束时间
//   "F": 0,             // 24小时内第一笔成交交易ID
//   "L": 18150,         // 24小时内最后一笔成交交易ID
//   "n": 18151          // 24小时内成交数
// }
// {
//     "e": "24hrMiniTicker",  // 事件类型
//     "E": 123456789,         // 事件时间
//     "s": "BNBBTC",          // 交易对
//     "c": "0.0025",          // 最新成交价格
//     "o": "0.0010",          // 24小时前开始第一笔成交价格
//     "h": "0.0025",          // 24小时内最高成交价
//     "l": "0.0010",          // 24小时内最低成交价
//     "v": "10000",           // 成交量
//     "q": "18"               // 成交额
//   }
class BaseHQData {
  int time = 0;
  ExchangeSymbol exchangeSymbol = ExchangeSymbol.BSC;
  String symbol = "";
  String nowPrice = "";
  String zdf = "";
  String kpj = "";
  String spj = "";
  String maxPrice = "";
  String minPrice = "";
  String cjl = "";
  String cje = "";
  String getZDF() {
    double np = double.parse(nowPrice);
    double kpjTemp = double.parse(kpj);
    double zdf = ((np - kpjTemp) / kpjTemp) * 100;
    return "${zdf.toStringAsFixed(2)}%";
  }

  @override
  String toString() {
    return "symbol:$symbol | nowPrice:$nowPrice | kpj:$kpj";
  }
}

class HQData extends BaseHQData {}
// {
//   "e": "kline",     // 事件类型
//   "E": 123456789,   // 事件时间
//   "s": "BNBBTC",    // 交易对
//   "k": {
//     "t": 123400000, // 这根K线的起始时间
//     "T": 123460000, // 这根K线的结束时间
//     "s": "BNBBTC",  // 交易对
//     "i": "1m",      // K线间隔
//     "f": 100,       // 这根K线期间第一笔成交ID
//     "L": 200,       // 这根K线期间末一笔成交ID
//     "o": "0.0010",  // 这根K线期间第一笔成交价
//     "c": "0.0020",  // 这根K线期间末一笔成交价
//     "h": "0.0025",  // 这根K线期间最高成交价
//     "l": "0.0015",  // 这根K线期间最低成交价
//     "v": "1000",    // 这根K线期间成交量
//     "n": 100,       // 这根K线期间成交笔数
//     "x": false,     // 这根K线是否完结(是否已经开始下一根K线)
//     "q": "1.0000",  // 这根K线期间成交额
//     "V": "500",     // 主动买入的成交量
//     "Q": "0.500",   // 主动买入的成交额
//     "B": "123456"   // 忽略此参数
//   }
// }
class KLineData {}
