import 'dart:convert';
import 'dart:io';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/net/api_manager.dart';
import 'package:stocks/net/net_adapter.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:stocks/manager/exchange_manager.dart';

class ProxyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..findProxy = _findProxy;
  }

  String _findProxy(url) {
    return HttpClient.findProxyFromEnvironment(url, environment: {
      "http_proxy": "127.0.0.1:7890",
      "https_proxy": "127.0.0.1:7890"
    });
  }
}
enum SubscriptionAction {
  subscription,
  unsubscription
}
enum SubscriptionType {
  kline,
  baseHQ,
  HQ,
}

class SubscriptionParm {
  int? id;
  ExchangeSymbol symbol;
  SubscriptionAction? action;
  SubscriptionType type = SubscriptionType.baseHQ;
  Pair pair = Pair();
  String? otherParm;
  SubscriptionParm(this.symbol, this.type, this.pair, {this.action = SubscriptionAction.subscription, this.otherParm = "", this.id = 1});
}

class _SocketInfo {
  late _Socket socket;
  ExchangeSymbol? symbol;
  Adapter? adapter;
  Map<String, List<void Function(dynamic)>> subscriptionerFunc = {};
  Map<String, List<void Function(dynamic)>> onErrorFunc = {};
  Map<String, List<void Function()>> onSuccFunc = {};
  onData(dynamic message) {
    assert(adapter != null);
    String key = adapter!.getMessageKey(message);
    if (this.subscriptionerFunc.keys.length > 0) {
      List<void Function(dynamic)>? funcs = this.subscriptionerFunc[key];
      if (funcs != null && funcs.length > 0) {
        funcs.forEach((element) {
          element(adapter!.parseData(message));
        });
      }
      // for (var item in this.subscriptionerFunc) {}
    }
  }
}

class SocketManager {
  Map<ExchangeSymbol, _SocketInfo?> socketMap = {};
  static SocketManager? _instance;

  SocketManager._();

  static instance() {
    if (_instance == null) {
      _instance = SocketManager._();
      HttpOverrides.global = ProxyHttpOverrides();
    }
    return _instance;
  }

  Adapter? _getAdapter(ExchangeSymbol symbol) {
    switch (symbol) {
      case ExchangeSymbol.BSC:
        return BscAdapter() as Adapter;
      default:
        return null;
    }
  }

  subscription(SubscriptionParm parm, void Function(dynamic) onData,
      [void Function()? onSucc, void Function(dynamic error)? onError]) {
    Adapter? a = this._getAdapter(parm.symbol);
    assert(a != null);
    this._startSocket(
        parm.symbol, a!.generateKey(parm), onData, onSucc, onError);

    this._sendMessage(parm.symbol, a.generateSendMessage(parm));
  }

  unsubscription(SubscriptionParm parm,
      [void Function()? onSucc, void Function(dynamic error)? onError]) {
    Adapter? a = this._getAdapter(parm.symbol);
    assert(a != null);

    this._sendMessage(parm.symbol, a!.generateSendMessage(parm));
  }

  _SocketInfo initSocket(ExchangeSymbol symbol) {
    String url = APIManager.instance().getSocketAPI(symbol);
    _SocketInfo r = _SocketInfo();
    r.socket = _Socket(url);
    r.symbol = symbol;
    r.adapter = this._getAdapter(symbol);
    return r;
  }

  _startSocket(ExchangeSymbol symbol, String key,
      [void Function(dynamic)? onData,
      void Function()? onSucc,
      void Function(dynamic error)? onError]) {
    _SocketInfo? s = socketMap[symbol];
    if (s == null) {
      s = initSocket(symbol);
      socketMap[symbol] = s;
    }
    s.socket.start(s.onData, onError);
    if (onData != null) {
      List<void Function(dynamic)>? funcs = s.subscriptionerFunc[key];
      if (funcs == null) {
        funcs = [];
      }
      funcs.add(onData);
      s.subscriptionerFunc[key] = funcs;
    }
    if (onError != null) {
      List<void Function(dynamic)>? funcs = s.onErrorFunc[key];
      if (funcs == null) {
        funcs = [];
      }
      funcs.add(onError);
      s.onErrorFunc[key] = funcs;
    }
    if (onSucc != null) {
      List<void Function()>? funcs = s.onSuccFunc[key];
      if (funcs == null) {
        funcs = [];
      }
      funcs.add(onSucc);
      s.onSuccFunc[key] = funcs;
    }
  }

  _sendMessage(ExchangeSymbol symbol, dynamic message) {
    _SocketInfo? s = socketMap[symbol];
    s!.socket.send(message);
  }

  _closeSocket(ExchangeSymbol symbol) {
    _SocketInfo? s = socketMap[symbol];
    if (s != null) {
      s.socket.close();
      socketMap[symbol] = null;
    }
  }
}

class _Socket {
  late IOWebSocketChannel channel;
  _Socket(String url) {
    this.channel = IOWebSocketChannel.connect(url);
  }

  start(void Function(dynamic) onData, void Function(dynamic)? onError) {
    this.channel.stream.listen((message) {
      print(message);
      onData(message);
    }, onError: (error) {
      if (onError != null) {
        onError(error);
      }
      print(error);
    }, onDone: () {
      print('onDone');
    });
  }

  send(dynamic message) {
    String m = JsonEncoder().convert(message);
    print(m);
    channel.sink.add(m);
  }

  close() {
    channel.sink.close(status.goingAway);
  }
}
