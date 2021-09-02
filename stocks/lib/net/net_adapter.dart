import 'dart:convert';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/models/dataModel.dart';
import 'socket_manager.dart';

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
  String subscription(SubscriptionParm parm) => "";
  String unsubscription(SubscriptionParm parm) => "";
}

class Adapter with DataAdapterProtocol, SocketAdapterProtocol {
  static Adapter? getAdapterWith(ExchangeSymbol symbol) {
    switch (symbol) {
      case ExchangeSymbol.BSC:
        return BscAdapter() as Adapter;
      default:
        return null;
    }
  }
}

/// 币安交易所网络请求适配器
class BscAdapter extends Adapter {
  @override
  String subscription(SubscriptionParm parm) {
    String streamName = getSocketStreamName(parm.type);
    List<String> streamNameWithParm = [];
    parm.pairs.forEach((pair) {
      String symbol = pair.symbol.toLowerCase();
      streamNameWithParm.add(
          "$symbol${this.getSocketStreamName(parm.type)}${parm.otherParm}");
    });
    return JsonEncoder().convert(
        {"method": "SUBSCRIBE", "params": streamNameWithParm, "id": parm.id});
  }

  @override
  String unsubscription(SubscriptionParm parm) {
    String streamName = getSocketStreamName(parm.type);
    List<String> streamNameWithParm = [];
    parm.pairs.forEach((pair) {
      String symbol = pair.symbol.toLowerCase();
      streamNameWithParm.add(
          "$symbol${this.getSocketStreamName(parm.type)}${parm.otherParm}");
    });
    return JsonEncoder().convert(
        {"method": "UNSUBSCRIBE", "params": streamNameWithParm, "id": parm.id});
  }

  @override 
  SubscriptionType? filterDataType(dynamic data){
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

  // @override
  // dynamic? parseData(dynamic data) {
  //   String streamName = _getMessageStreamName(data);
  //   switch (streamName) {
  //     case "@ticker":
  //       return parseHQ(data);
  //     case "@miniTicker":
  //       return parseBaseHQ(data);
  //     case "@kline":
  //       return parseKline(data);
  //     default:
  //       return null;
  //   }
  // }

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
    r.symbol = obj["s"];
    r.nowPrice = obj["c"];
    r.kpj = obj["o"];
    r.maxPrice = obj["h"];
    r.minPrice = obj["l"];
    r.cjl = obj["v"];
    r.cje = obj["q"];
    r.zdf = r.getZDF();
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
