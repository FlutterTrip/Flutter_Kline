import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stocks/tools/tools.dart';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/models/dataModel.dart';
import 'package:stocks/net/socket_manager.dart';
import 'socket_manager.dart';

String http_proxy = "127.0.0.1:7890";
String https_proxy = "127.0.0.1:7890";

/// 返回的原始数据进行解析，每个交易所都不一样，需要自行去实现不同的适配器
mixin DataAdapterProtocol {
  SubscriptionType? filterDataType(dynamic data) => null;
  // dynamic? parseData(dynamic data) => null;
  BaseHQData parseBaseHQ(dynamic data) => BaseHQData();
  HQData parseHQ(dynamic data) => HQData();
  KLineData parseKline(dynamic data) => KLineData();
}

/// 关于 websocket 请求时对于返回的信息区分，定义生成 key，通过返回的信息获取 key，具体实现每个交易所都不一样
mixin SocketAdapterProtocol {
  List<String> subscription(SubscriptionParm parm) => [];
  List<String> unsubscription(SubscriptionParm parm) => [];
  dynamic pingPong(dynamic _socket, dynamic message) => message;
  dynamic gzip(dynamic message) => message;
}

class Adapter with DataAdapterProtocol, SocketAdapterProtocol {
  static Adapter? getAdapterWith(ExchangeSymbol symbol) {
    switch (symbol) {
      case ExchangeSymbol.BSC:
        return BscAdapter() as Adapter;
      case ExchangeSymbol.HB:
        return HBAdapter() as Adapter;
      case ExchangeSymbol.OK:
        return OKAdapter() as Adapter;
      default:
        return null;
    }
  }
}

// 欧易适配器
class OKAdapter extends Adapter {
  @override
  List<String> subscription(SubscriptionParm parm) {
    if (SubscriptionType.baseHQ == parm.type ||
        SubscriptionType.HQ == parm.type) {
      List<Map> streamNameWithParm = [];
      parm.pairs.forEach((pair) {
        String instId = pair.otherParm["instId"] ?? "";
        if (instId == "") {
          instId =
              "${pair.token0.symbol.toUpperCase()}-${pair.token1.symbol.toUpperCase()}";
        }
        streamNameWithParm.add({"channel": "tickers", "instId": instId});
      });
      return [
        JsonEncoder().convert({"op": "subscribe", "args": streamNameWithParm})
      ];
    }
    return [];
  }

  @override
  SubscriptionType? filterDataType(dynamic data) {
    if (data is String && data.length > 0 && data != "pong") {
      Map obj = JsonDecoder().convert(data);
      String ch = obj["arg"]["channel"] ?? "";
      if (ch.indexOf("ticker") >= 0 && obj["data"] != null) {
        return SubscriptionType.baseHQ;
      }
    }
  }

  @override
  List<String> unsubscription(SubscriptionParm parm) {
    if (SubscriptionType.baseHQ == parm.type ||
        SubscriptionType.HQ == parm.type) {
      List<Map> streamNameWithParm = [];
      parm.pairs.forEach((pair) {
        String instId = pair.otherParm["instId"] ?? "";
        if (instId == "") {
          instId =
              "${pair.token0.symbol.toUpperCase()}-${pair.token1.symbol.toUpperCase()}";
        }
        streamNameWithParm.add({"channel": "tickers", "instId": instId});
      });
      return [
        JsonEncoder().convert({"op": "unsubscribe", "args": streamNameWithParm})
      ];
    }
    return [];
  }

  Function ping = GNTools().throttle((socket) {
    if (socket != null) {
      socket.send("ping");
    }
    return Future.sync(() => null);
  }, 30000);

  @override
  dynamic pingPong(socket, message) {
    if (socket.send != null) {
      ping([socket]);
    }
    return message;
  }

  @override
  parseBaseHQ(dynamic data) {
//     {
//     "arg": {
//         "channel": "tickers",
//         "instId": "LTC-USD-200327"
//     },
//     "data": [{
//         "instType": "SWAP",
//         "instId": "LTC-USD-SWAP",
//         "last": "9999.99",
//         "lastSz": "0.1",
//         "askPx": "9999.99",
//         "askSz": "11",
//         "bidPx": "8888.88",
//         "bidSz": "5",
//         "open24h": "9000",
//         "high24h": "10000",
//         "low24h": "8888.88",
//         "volCcy24h": "2222",
//         "vol24h": "2222",
//         "sodUtc0": "2222",
//         "sodUtc8": "2222",
//         "ts": "1597026383085"
//     }]
// }

    Map source = JsonDecoder().convert(data);
    Map obj = source["data"][0];
    BaseHQData r = BaseHQData();
    r.time = int.parse(obj["ts"]);
    List t = obj["instId"].toString().split("-");
    r.symbol =
        "${t[0].toString().toLowerCase()}${t[1].toString().toLowerCase()}";
    r.nowPrice = obj["last"].toString();
    r.kpj = obj["open24h"].toString();
    r.maxPrice = obj["high24h"].toString();
    r.minPrice = obj["low24h"].toString();
    r.cjl = obj["vol24h"].toString();
    // r.cje = obj["q"];
    r.zdf = r.getZDF();
    r.exchangeSymbol = ExchangeSymbol.OK;
    return r;
  }
}

// 火币适配器
class HBAdapter extends Adapter {
  @override
  List<String> subscription(SubscriptionParm parm) {
    if (SubscriptionType.baseHQ == parm.type ||
        SubscriptionType.HQ == parm.type) {
      List<String> streamNameWithParm = [];
      parm.pairs.forEach((pair) {
        String symbol = pair.symbol.toLowerCase();
        streamNameWithParm
            .add(JsonEncoder().convert({"sub": "market.$symbol.ticker"}));
      });
      return streamNameWithParm;
    }
    return [];
  }

  @override
  SubscriptionType? filterDataType(dynamic data) {
    if (data is String && data.length > 0) {
      Map obj = JsonDecoder().convert(data);
      String ch = obj["ch"] ?? "";
      if (ch.indexOf("ticker") >= 0) {
        return SubscriptionType.baseHQ;
      }
    }
  }

  @override
  List<String> unsubscription(SubscriptionParm parm) {
    if (SubscriptionType.baseHQ == parm.type ||
        SubscriptionType.HQ == parm.type) {
      List<String> streamNameWithParm = [];
      parm.pairs.forEach((pair) {
        String symbol = pair.symbol.toLowerCase();
        streamNameWithParm.add(JsonEncoder()
            .convert({"unsub": "market.$symbol.ticker", "id": parm.id}));
      });
      return streamNameWithParm;
    }
    return [];
  }

  @override
  dynamic gzip(message) {
    List<int> t = GZipCodec().decode(message);
    return utf8.decode(t);
  }

  @override
  dynamic pingPong(socket, message) {
    Map obj = JsonDecoder().convert(message);
    if (obj["ping"] != null && socket.send != null) {
      socket.send(JsonEncoder().convert({"pong": obj["ping"]}));
      return "";
    }
    return message;
  }

  @override
  parseBaseHQ(dynamic data) {
    Map source = JsonDecoder().convert(data);
    Map obj = source["tick"];
    BaseHQData r = BaseHQData();
    r.time = source["ts"];
    r.symbol = source["ch"].toString().split(".")[1];
    r.nowPrice = obj["lastPrice"].toString();
    r.kpj = obj["open"].toString();
    r.maxPrice = obj["high"].toString();
    r.minPrice = obj["low"].toString();
    r.cjl = obj["vol"].toString();
    // r.cje = obj["q"];
    r.zdf = r.getZDF();
    r.exchangeSymbol = ExchangeSymbol.HB;
    return r;
  }
}

/// 币安交易所网络请求适配器
class BscAdapter extends Adapter {
  @override
  List<String> subscription(SubscriptionParm parm) {
    String streamName = getSocketStreamName(parm.type);
    List<String> streamNameWithParm = [];
    parm.pairs.forEach((pair) {
      String symbol = pair.symbol.toLowerCase();
      streamNameWithParm.add(
          "$symbol${this.getSocketStreamName(parm.type)}${parm.otherParm}");
    });
    return [
      JsonEncoder().convert(
          {"method": "SUBSCRIBE", "params": streamNameWithParm, "id": parm.id})
    ];
  }

  @override
  List<String> unsubscription(SubscriptionParm parm) {
    String streamName = getSocketStreamName(parm.type);
    List<String> streamNameWithParm = [];
    parm.pairs.forEach((pair) {
      String symbol = pair.symbol.toLowerCase();
      streamNameWithParm.add(
          "$symbol${this.getSocketStreamName(parm.type)}${parm.otherParm}");
    });
    return [
      JsonEncoder().convert({
        "method": "UNSUBSCRIBE",
        "params": streamNameWithParm,
        "id": parm.id
      })
    ];
  }

  @override
  SubscriptionType? filterDataType(dynamic data) {
    String streamName = _getMessageStreamName(data);
    switch (streamName) {
      case "@ticker":
        return SubscriptionType.HQ;
      case "@miniTicker":
        return SubscriptionType.baseHQ;
      case "@kline":
        return SubscriptionType.kline;
      default:
        return null;
    }
  }

  String getSocketStreamName(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.HQ:
        return "@ticker";
      case SubscriptionType.baseHQ:
        return "@miniTicker";
      case SubscriptionType.kline:
        return "@kline";
      default:
        return "";
    }
  }

  String _getMessageStreamName(dynamic data) {
    Map obj = JsonDecoder().convert(data);
    String streamName = obj["e"] ?? "";
    switch (streamName) {
      case "24hrTicker":
        streamName = "@ticker";
        break;
      case "24hrMiniTicker":
        streamName = "@miniTicker";
        break;
      default:
        streamName = "@$streamName";
        break;
    }
    return streamName;
  }

  @override
  parseBaseHQ(dynamic data) {
    Map obj = JsonDecoder().convert(data);
    BaseHQData r = BaseHQData();
    r.time = obj["E"];
    r.symbol = obj["s"].toString().toLowerCase();
    r.nowPrice = obj["c"];
    r.kpj = obj["o"];
    r.maxPrice = obj["h"];
    r.minPrice = obj["l"];
    r.cjl = obj["v"];
    r.cje = obj["q"];
    r.zdf = r.getZDF();
    r.exchangeSymbol = ExchangeSymbol.BSC;
    return r;
  }

  @override
  parseHQ(dynamic data) {
    // TODO: implement parseHQ
    throw UnimplementedError();
  }

  @override
  parseKline(dynamic data) {
    // TODO: implement parseKline
    throw UnimplementedError();
  }
}
