import 'dart:convert';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/net/http.dart';
import 'package:stocks/net/api_manager.dart';


enum HqIntervalType {
  m, h, d, w, M
}

class HqNet {
  static Future getAllHqData(ExchangeSymbol symbol, Pair piar, {HqIntervalType? intervalType = HqIntervalType.d, int? intervalNum = 1} ) {
    String? klineUrl = APIManager.getApi(symbol, apiType.kline);
    String? baseUrl = APIManager.getApi(symbol, apiType.baseUrl);
    return Net.get("$baseUrl$klineUrl",queryParameters: {
      "symbol": piar.symbol.toUpperCase(),
      "interval": "1d",
      "limit": "100"
    }).then((value) {
      List obj = value.data;
      List<HqChartData> r = [];
  //     [
  //   1499040000000,      // 开盘时间0
  //   "0.01634790",       // 开盘价1
  //   "0.80000000",       // 最高价2
  //   "0.01575800",       // 最低价3
  //   "0.01577100",       // 收盘价(当前K线未结束的即为最新价)4
  //   "148976.11427815",  // 成交量5
  //   1499644799999,      // 收盘时间6
  //   "2434.19055334",    // 成交额7
  //   308,                // 成交笔数8
  //   "1756.87402397",    // 主动买入成交量9
  //   "28.46694368",      // 主动买入成交额10
  //   "17928899.62484339" // 请忽略该参数11
  // ]
      obj.forEach((element) {
        HqChartData d = HqChartData();
        d.time = element[0];
        d.kpj = element[1];
        d.spj = element[4];
        d.maxPrice = element[2];
        d.minPrice = element[3];
        d.exchangeSymbol = symbol;
        r.add(d);
      });
      return r;
    });
  }
}