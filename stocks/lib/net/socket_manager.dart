import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stocks/components/exchange_symbols/exchange_symbols.dart';
import 'package:stocks/models/dataModel.dart';
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
    return HttpClient.findProxyFromEnvironment(url,
        environment: {"http_proxy": http_proxy, "https_proxy": https_proxy});
  }
}

enum SubscriptionAction { subscription, unsubscription }
enum SubscriptionType {
  kline,
  baseHQ,
  HQ,
}

class SubscriptionParm {
  int? id;
  String name = "";
  ExchangeSymbol symbol;
  SubscriptionAction? action;
  SubscriptionType type = SubscriptionType.baseHQ;
  void Function(dynamic)? subscriptionerFunc;
  void Function(dynamic)? onErrorFunc;
  void Function()? onSuccFunc;
  void Function()? onDone;
  List<Pair> pairs = [];
  String? otherParm;
  SubscriptionParm(this.symbol, this.type, this.pairs, this.name,
      {this.action = SubscriptionAction.subscription,
      this.otherParm = "",
      this.id = 1});
}

class _SocketInfo {
  late _Socket socket;
  late ExchangeSymbol symbol;
  Adapter? adapter;
  Map<SubscriptionType, List<SubscriptionParm>> subscriptionerParm = {};
  onData(dynamic message) {
    message = adapter!.gzip(message);
    message = adapter!.pingPong(socket, message);

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

mixin SocketProtocal {
  onData(dynamic message) {}
  onDone(ExchangeSymbol symbol) {}
  onError() {}
}

class SocketManager {
  Map<ExchangeSymbol, _SocketInfo?> socketMap = {};
  Map<SocketProtocal, List<SubscriptionParm>?> delegateMap = {};
  Map<SocketProtocal, Map<SubscriptionType, List<String>?>?> subTypeKeyMap = {};
  static SocketManager? _instance;

  SocketManager._();

  static registerDelegate(SocketProtocal widget) {
    if (SocketManager.instance().delegateMap[widget] == null) {
      SocketManager.instance().delegateMap[widget] = [];
    }
  }

  static addSubscriptionParm(
      SocketProtocal widget, List<SubscriptionParm> parms) {
    if (SocketManager.instance().delegateMap[widget] == null) {
      SocketManager.instance().delegateMap[widget] = [];
    }
    List<SubscriptionParm> parmsTemp =
        SocketManager.instance().delegateMap[widget] ?? [];
    SocketManager.instance().delegateMap[widget] = [...parmsTemp, ...parms];
    SocketManager m = SocketManager.instance();
    m._updateSubTypeKeyMap(widget, parms);
  }

  _updateSubTypeKeyMap(SocketProtocal widget, List<SubscriptionParm> parms) {
    parms.forEach((parm) {
      if (this.subTypeKeyMap[widget] == null) {
        this.subTypeKeyMap[widget] = {};
      }
      if (this.subTypeKeyMap[widget]![parm.type] == null) {
        this.subTypeKeyMap[widget]![parm.type] = [];
      }
      List<String> pairs = [];
      List<String> pairsTemp = this.subTypeKeyMap[widget]![parm.type]!;
      parm.pairs.forEach((element) {
        if (pairsTemp.indexOf(element.symbol) < 0) {
          pairs.add(element.symbol);
        }
      });
      this.subTypeKeyMap[widget]![parm.type]!.addAll(pairs);
    });
  }

  static updateSubscriptionParm(
      SocketProtocal widget, List<SubscriptionParm> parms) {
    List<SubscriptionParm> parmsTemp =
        SocketManager.instance().delegateMap[widget] ?? [];
    if (parmsTemp.length == 0) {
      SocketManager.addSubscriptionParm(widget, parms);
      return;
    }
    List<SubscriptionParm> needUpdate = [];
    parmsTemp.forEach((element) {
      parms.forEach((newParm) {
        if (newParm.type == element.type) {
          needUpdate.add(element);
        }
      });
    });
    needUpdate.forEach((element) {
      parmsTemp.remove(element);
    });
    parmsTemp = [...parms, ...parmsTemp];
    SocketManager.instance().delegateMap[widget] = parmsTemp;
    SocketManager.instance()._updateSubTypeKeyMap(widget, parmsTemp);
    SocketManager.socketStart(widget);
  }

  static disposeDelegate(SocketProtocal widget) {
    SocketManager.instance().delegateMap.remove(widget);
  }

  static socketStart(SocketProtocal widget) {
    SocketManager m = SocketManager.instance();
    m.delegateMap[widget]?.forEach((parm) {
      Map<ExchangeSymbol, List<Pair>> l = {};
      parm.pairs.forEach((pair) {
        pair.exchangeSymbol.forEach((ex) {
          if (l[ex] == null) {
            l[ex] = [];
          }
          l[ex]!.add(pair);
        });
      });

      l.forEach((symbol, value) {
        m._startSocketT(symbol);
        Adapter? a = Adapter.getAdapterWith(symbol);
        assert(a != null);
        m._sendMessage(symbol, a!.subscription(parm));
      });
    });
  }

  static SocketManager instance() {
    if (_instance == null) {
      _instance = SocketManager._();
      HttpOverrides.global = ProxyHttpOverrides();
    }
    return _instance!;
  }

  subscription(
    SubscriptionParm parm,
    // void Function(dynamic) onData,
    // {void Function()? onSucc,
    // void Function(dynamic error)? onError,
    // void Function(SubscriptionParm)? onDone}
  ) {
    Adapter? a = Adapter.getAdapterWith(parm.symbol);
    assert(a != null);
    // parm.subscriptionerFunc = onData;
    // parm.onErrorFunc = (error) {
    //   print(error);
    //   if (onError != null) {
    //     onError(error);
    //   }
    // };
    // parm.onSuccFunc = onSucc;
    // parm.onDone = (parm) {

    //   if (onDone != null) {
    //     onDone(parm);
    //   }
    // };
    this._startSocket(parm, () {
      print('${parm.symbol} onDone');
      socketMap[parm.symbol] = null;
      if (parm.onDone != null) {
        parm.onDone!();
      }
    });

    this._sendMessage(parm.symbol, a!.subscription(parm));
  }

  unsubscription(SubscriptionParm parm,
      [void Function()? onSucc, void Function(dynamic error)? onError]) {
    Adapter? a = Adapter.getAdapterWith(parm.symbol);
    assert(a != null);
    socketMap.forEach((key, value) {
      if (parm.symbol == key && value != null) {
        value.subscriptionerParm.forEach((key2, value2) {
          if (key2 == parm.type) {
            List<SubscriptionParm> delObj = [];
            for (var i = 0; i < value2.length; i++) {
              SubscriptionParm element = value2[i];
              if (element.name == parm.name) {
                delObj.add(element);
              }
            }
            if (delObj.length > 0) {
              delObj.forEach((obj) {
                value2.remove(obj);
              });
            }
            print("unsubscription ${parm.symbol}");
            // if (value2.length == 0) {
            //   value.socket.close();
            // }
            if (parm.pairs.length > 0) {
              this._sendMessage(parm.symbol, a!.unsubscription(parm));
            }
          }
        });
      }
    });
  }

  _SocketInfo initSocket(ExchangeSymbol symbol) {
    String url =
        APIManager.getApi(symbol, apiType.baseUrl, reqType: apiReqType.socket)!;
    _SocketInfo r = _SocketInfo();
    r.socket = _Socket(url);
    r.symbol = symbol;
    r.adapter = Adapter.getAdapterWith(symbol);
    return r;
  }

  _startSocketT(ExchangeSymbol symbol) {
    _SocketInfo? s = socketMap[symbol];
    if (s == null) {
      s = initSocket(symbol);
      socketMap[symbol] = s;
    }
    if (s.socket.channel?.innerWebSocket == null) {
      s.socket.start((message) => _onData(s!, message),
          (message) => _onError(s!, message), () => _onDone(s!));
    }
  }

  _onDone(_SocketInfo socketInfo) {
    if (this.delegateMap.keys.length > 0) {
      this.delegateMap.forEach((key, value) {
        key.onDone(socketInfo.symbol);
      });
    }
  }

  _onData(_SocketInfo socketInfo, dynamic message) {
    // print(socketInfo.symbol);
    Adapter? adapter = socketInfo.adapter;
    assert(adapter != null);
    message = adapter!.gzip(message);
    message = adapter.pingPong(socketInfo.socket, message);
    SubscriptionType? type = adapter.filterDataType(message);

    if (this.delegateMap.keys.length > 0 && type != null) {
      List<SocketProtocal> widgets = [];
      this.delegateMap.forEach((key, value) {
        if (value != null && value.length > 0) {
          value.forEach((element) {
            if (element.type == type && widgets.indexOf(key) < 0) {
              widgets.add(key);
            }
          });
        }
      });

      widgets.forEach((widget) {
        List<String> subKeys = this.subTypeKeyMap[widget]?[type] ?? [];
        BaseHQData? data;
        if (subKeys.length > 0) {
          switch (type) {
            case SubscriptionType.HQ:
              data = adapter.parseHQ(message);
              break;
            case SubscriptionType.baseHQ:
              data = adapter.parseBaseHQ(message);
              break;
            case SubscriptionType.kline:
              data = adapter.parseKline(message);
              break;
            default:
              break;
          }

          if (data != null && subKeys.indexOf(data.symbol) >= 0) {
            widget.onData(data);
          }
        }
      });
    }
  }

  _onError(_SocketInfo socketInfo, dynamic message) {}

  _startSocket(SubscriptionParm parm, void Function() ondone) {
    ExchangeSymbol symbol = parm.symbol;
    _SocketInfo? s = socketMap[symbol];
    if (s == null) {
      s = initSocket(symbol);
      socketMap[symbol] = s;
    }
    if (s.socket.channel?.innerWebSocket == null) {
      s.socket.start(s.onData, parm.onErrorFunc, ondone);
    }

    List<SubscriptionParm>? parms = s.subscriptionerParm[parm.type];
    if (parms == null) {
      parms = [];
    }
    // 做一次清理，删除重复的
    List<SubscriptionParm> delObj = [];
    for (var i = 0; i < parms.length; i++) {
      SubscriptionParm element = parms[i];
      if (element.name == parm.name) {
        delObj.add(element);
      }
    }
    if (parms.length > 0 && delObj.length > 0) {
      delObj.forEach((element) {
        parms!.remove(element);
      });
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

  start(void Function(dynamic) onData, void Function(dynamic)? onError,
      void Function()? onDone) {
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
        if (onDone != null) {
          onDone();
        }
      });
    }
  }

  send(dynamic message) {
    if (message is List && message.length > 0) {
      message.forEach((element) {
        print("socket send: $element");
        channel!.sink.add(element);
      });
    } else {
      print("socket send: $message");
      channel!.sink.add(message);
    }
  }

  close() {
    channel!.sink.close(status.goingAway);
  }
}
