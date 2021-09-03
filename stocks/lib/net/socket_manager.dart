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
  void Function(dynamic)? subscriptionerFunc;
  void Function(dynamic)? onErrorFunc;
  void Function()? onSuccFunc;
  List<Pair> pairs = [Pair()];
  String? otherParm;
  SubscriptionParm(this.symbol, this.type, this.pairs, {this.action = SubscriptionAction.subscription, this.otherParm = "", this.id = 1});
}

class _SocketInfo {
  late _Socket socket;
  ExchangeSymbol? symbol;
  Adapter? adapter;
  Map<SubscriptionType, List<SubscriptionParm>> subscriptionerParm = {};
  onData(dynamic message) {
    assert(adapter != null);
    SubscriptionType? key = adapter!.filterDataType(message);
    if (this.subscriptionerParm.keys.length > 0 && key != null) {
      List<SubscriptionParm>? funcs = this.subscriptionerParm[key];
      if (funcs != null && funcs.length > 0) {
        funcs.forEach((parm) {
            void Function(dynamic) element = parm.subscriptionerFunc!;
            switch (key) {
            case SubscriptionType.HQ:
              element(adapter!.parseHQ(message));
              break;
            case SubscriptionType.baseHQ:
              element(adapter!.parseBaseHQ(message));
              break;
            case SubscriptionType.kline:
              element(adapter!.parseKline(message));
              break;
            default:
              element(message);
              break;
          }
        });
      }
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

  subscription(SubscriptionParm parm, void Function(dynamic) onData,
      [void Function()? onSucc, void Function(dynamic error)? onError]) {
    Adapter? a = Adapter.getAdapterWith(parm.symbol);
    assert(a != null);
    parm.subscriptionerFunc = onData;
    parm.onErrorFunc = onError;
    parm.onSuccFunc = onSucc;
    this._startSocket(parm);

    this._sendMessage(parm.symbol, a!.subscription(parm));
  }

  unsubscription(SubscriptionParm parm,
      [void Function()? onSucc, void Function(dynamic error)? onError]) {
    Adapter? a = Adapter.getAdapterWith(parm.symbol);
    assert(a != null);
    this._sendMessage(parm.symbol, a!.unsubscription(parm));
  }

  _SocketInfo initSocket(ExchangeSymbol symbol) {
    String url = APIManager.instance().getSocketAPI(symbol);
    _SocketInfo r = _SocketInfo();
    r.socket = _Socket(url);
    r.symbol = symbol;
    r.adapter = Adapter.getAdapterWith(symbol);
    return r;
  }

  _startSocket(SubscriptionParm parm) {
    ExchangeSymbol symbol = parm.symbol;
    _SocketInfo? s = socketMap[symbol];
    if (s == null) {
      s = initSocket(symbol);
      socketMap[symbol] = s;
      s.socket.start(s.onData, parm.onErrorFunc);
    }
    List<SubscriptionParm>? parms = s.subscriptionerParm[parm.type];
    if (parms == null) {
      parms = [];
    }
    parms.add(parm);
    s.subscriptionerParm[parm.type] = parms;
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
  IOWebSocketChannel? channel;
  _Socket(String url) {
    this.channel = IOWebSocketChannel.connect(url);
  }

  start(void Function(dynamic) onData, void Function(dynamic)? onError) {
    if (this.channel != null) {
      // if (this.channel.stream. != status.abnormalClosure)
      this.channel!.stream.listen((message) {
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
    
  }

  send(dynamic message) {
    channel!.sink.add(message);
  }

  close() {
    channel!.sink.close(status.goingAway);
  }
}
