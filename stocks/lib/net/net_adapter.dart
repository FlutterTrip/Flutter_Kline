import 'dart:convert';
import 'package:stocks/models/dataModel.dart';
import 'socket_manager.dart';

/// 返回的原始数据进行解析，每个交易所都不一样，需要自行去实现不同的适配器
mixin DataAdapterProtocol {
  dynamic? parseData(dynamic data) => null;
  BaseHQData parseBaseHQ(dynamic data) => BaseHQData();
  HQData parseHQ(dynamic data) => HQData();
  KLineData parseKline(dynamic data) => KLineData();
}

/// 关于 websocket 请求时对于返回的信息区分，定义生成 key，通过返回的信息获取 key，具体实现每个交易所都不一样
mixin SocketAdapterProtocol {
  getMessageKey(dynamic data) => "";
  String generateKey(SubscriptionParm parm) => "";
  Map generateSendMessage(SubscriptionParm parm) => {};
}

class Adapter with DataAdapterProtocol, SocketAdapterProtocol {}

/// 币安交易所网络请求适配器
class BscAdapter extends Adapter {
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

  dynamic? parseData(dynamic data) {
    String streamName = _getMessageStreamName(data);
    switch (streamName) {
      case "@ticker":
        return parseHQ(data);
      case "@miniTicker":
        return parseBaseHQ(data);
      case "@kline":
        return parseKline(data);
      default:
        return null;
    }
  }

  @override
  String generateKey(SubscriptionParm parm) {
    String symbol = parm.pair.symbol.toLowerCase();
    return "$symbol${this.getSocketStreamName(parm.type)}${parm.otherParm}";
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
  getMessageKey(dynamic data) {
    Map obj = JsonDecoder().convert(data);
    String symbol = obj["s"] ?? "";
    symbol = symbol.toLowerCase();
    String streamName = _getMessageStreamName(data);
    String otherParm = "";
    if (streamName == '@kline') {
      otherParm = "_${obj['k']!['i']!}";
    }
    return "$symbol$streamName$otherParm";
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

  @override
  Map generateSendMessage(SubscriptionParm parm) {
    Map r = {
      "method": parm.action == SubscriptionAction.subscription
          ? "SUBSCRIBE"
          : "UNSUBSCRIBE",
      "params": [this.generateKey(parm)],
      "id": parm.id
    };
    return r;
  }
}
