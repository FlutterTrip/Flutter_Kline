import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stocks/components/exchange_symbols/exchange_symbols.dart';
import 'package:stocks/models/dataModel.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/net/api_manager.dart';
import 'package:stocks/net/net_adapter.dart';
import 'package:stocks/tools/tools.dart';
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
  List<Pair> pairs = [];
  String? otherParm;
  SubscriptionParm(this.symbol, this.type, this.pairs, this.name,
      {this.action = SubscriptionAction.subscription,
      this.otherParm = "",
      this.id = 1});
  copy() {
    return SubscriptionParm(this.symbol, this.type, [...this.pairs], this.name,
        action: this.action, otherParm: this.otherParm, id: this.id);
  }
}

class _SocketInfo {
  late _Socket socket;
  late ExchangeSymbol symbol;
  late Adapter? adapter;
  int status = 0; // 0 normal -1 closing
}

mixin SocketProtocal {
  onData(dynamic message) {}
  onDone(ExchangeSymbol symbol) {}
  onError() {}
}

class SocketManager {
  Map<ExchangeSymbol, _SocketInfo?> socketMap = {};
  Map<ExchangeSymbol, _SocketInfo?> willCloseSocketMap = {};
  Map<SocketProtocal, Map<SubscriptionType, SubscriptionParm?>?> delegateMap =
      {};
  Map<SubscriptionType, Map<ExchangeSymbol, Map<String, int>?>?>
      subTypeKeysNum = {};
  static SocketManager? _instance;

  SocketManager._();

  static registerDelegate(SocketProtocal widget) {
    if (SocketManager.instance().delegateMap[widget] == null) {
      SocketManager.instance().delegateMap[widget] = {};
    }
  }

  static subscription(SocketProtocal widget, List<SubscriptionParm> parms) {
    SocketManager m = SocketManager.instance();
    if (m.delegateMap[widget] == null) {
      m.delegateMap[widget] = {};
    }
    // List<SubscriptionParm> parmsTemp = m.delegateMap[widget] ?? [];
    // List<SubscriptionParm> newParms = [...parmsTemp, ...parms];
    Map<SubscriptionType, SubscriptionParm> t = {};
    parms.forEach((element) {
      t[element.type] = element;
    });
    m.delegateMap[widget] = t;
    SocketManager.socketStart(widget);
    // m._updateSubTypeKeyMap(widget);
    m._updateSubTypeKeysNum();
  }

  static unsubscription(SocketProtocal widget,
      [List<SubscriptionParm>? parms]) {
    SocketManager m = SocketManager.instance();
    if (m.socketMap.length == 0) {
      return;
    }
    List<SubscriptionParm> parmsTemp = parms ?? [];
    if (parms == null) {
      m.delegateMap[widget]?.forEach((key, value) {
        if (value != null) {
          parmsTemp.add(value.copy());
        }
      });
    }
    if (parmsTemp.length > 0) {
      parmsTemp.forEach((unsubparm) {
        SubscriptionParm? subParm = m.delegateMap[widget]![unsubparm.type];
        if (subParm != null) {
          List<Pair> needDel = [];
          subParm.pairs.forEach((element) {
            unsubparm.pairs.forEach((unelement) {
              if (element.symbol == unelement.symbol) {
                needDel.add(element);
              }
            });
          });
          needDel.forEach((element) {
            subParm.pairs.remove(element);
          });
        }
      });
      m._updateSubTypeKeysNum();

      parmsTemp.forEach((unsubparm) {
        List<Pair> needUnsub = [];
        unsubparm.pairs.forEach((pair) {
          if (m.subTypeKeysNum[unsubparm.type] != null) {
            if (m.subTypeKeysNum[unsubparm.type]![unsubparm.symbol] != null) {
              if (m.subTypeKeysNum[unsubparm.type]![unsubparm.symbol]![
                          pair.symbol] ==
                      null ||
                  m.subTypeKeysNum[unsubparm.type]![unsubparm.symbol]![
                          pair.symbol]! <=
                      0) {
                needUnsub.add(pair);
              }
            } else {
              needUnsub.add(pair);
            }
          } else {
            needUnsub.add(pair);
          }
        });
        if (needUnsub.length > 0) {
          needUnsub.forEach((element) {
            element.exchangeSymbol.forEach((symbol) {
              Adapter? a = m.socketMap[symbol]?.adapter;
              if (a != null) {
                List<Pair> temp = [];
                needUnsub.forEach((p) {
                  if (p.exchangeSymbol.indexOf(symbol) >= 0) {
                    temp.add(p);
                  }
                });
                unsubparm.pairs = temp;
                m._sendMessage(symbol, a.unsubscription(unsubparm));
              }
            });
          });
        }
      });

      Map<ExchangeSymbol, bool> isNeedClose = {};
      m.socketMap.forEach((key, value) {
        isNeedClose[key] = true;
      });
      m.subTypeKeysNum.forEach((key, value) {
        if (value != null) {
          value.forEach((key2, value2) {
            if (value2 != null) {
              value2.forEach((key3, value3) {
                if (value3 != null && value3 > 0) {
                  isNeedClose[key2] = false;
                }
              });
            }
          });
        }
      });
      List<ExchangeSymbol> symbols = [];
      isNeedClose.forEach((symbol, isNeedClose) {
        if (isNeedClose) {
          symbols.add(symbol);
        }
      });
      if (symbols.length > 0) {
        m._closeSocket(symbols);
      }
    }
  }

  Function _debounceClose = GNTools().debounce((symbols) {
    SocketManager m = SocketManager.instance();
    if (m.willCloseSocketMap.keys.length == 0) {
      print("cancel close pipe");
    }
    m.willCloseSocketMap.forEach((key, value) {
      if (value != null) {
        value.socket.close();
        value.status = -1;
        m.socketMap.remove(key);
        print("$key close");
      }
    });
    // symbols as List<ExchangeSymbol>;
    // symbols.forEach((symbol) {
    //   _SocketInfo? si = m.socketMap[symbol];
    //   if (si != null) {
    //     si.socket.close();
    //     si.status = -1;
    //     m.willCloseSocketMap[symbol] = si;
    //     m.socketMap.remove(symbol);
    //     print("$symbol close");
    //   }
    // });
  }, 5000);

  _closeSocket(List<ExchangeSymbol> symbols) {
    print("5s $symbols need close");
    symbols.forEach((element) {
      this.willCloseSocketMap[element] = this.socketMap[element];
    });
    this._debounceClose([symbols]);
  }

  // _updateSubTypeKeyMap(SocketProtocal widget) {
  // List<SubscriptionParm> parms = this.delegateMap[widget] ?? [];
  // parms.forEach((parm) {
  //   if (this.subTypeKeyMap[widget] == null) {
  //     this.subTypeKeyMap[widget] = {};
  //   }
  //   if (this.subTypeKeyMap[widget]![parm.type] == null) {
  //     this.subTypeKeyMap[widget]![parm.type] = [];
  //   }
  //   List<Pair> pairs = [];
  //   List<Pair> pairsTemp = this.subTypeKeyMap[widget]![parm.type]!;
  //   parm.pairs.forEach((element) {
  //     if (pairsTemp.indexOf(element.symbol) < 0) {
  //       pairs.add(element.symbol);
  //     }
  //   });
  //   List<String> newPairs = [...pairsTemp, ...pairs];
  //   this.subTypeKeyMap[widget]![parm.type] = newPairs;

  // if (this.subTypeKeysNum[parm.type] == null) {
  //   this.subTypeKeysNum[parm.type] = {};
  // }
  // newPairs.forEach((element) {
  //   if (this.subTypeKeysNum[parm.type]![element] == null) {
  //     this.subTypeKeysNum[parm.type]![element] = 0;
  //   }
  //   this.subTypeKeysNum[parm.type]![element] = this.subTypeKeysNum[parm.type]![element]! + 1;
  // });

  // });
  //  _updateSubTypeKeysNum();
  // }

  _updateSubTypeKeysNum() {
    this.subTypeKeysNum = {};
    this.delegateMap.forEach((widget, parmMap) {
      parmMap?.forEach((type, parm) {
        if (this.subTypeKeysNum[type] == null) {
          this.subTypeKeysNum[type] = {};
        }
        if (parm != null) {
          parm.pairs.forEach((pair) {
            pair.exchangeSymbol.forEach((symbol) {
              if (this.subTypeKeysNum[type]![symbol] == null) {
                this.subTypeKeysNum[type]![symbol] = {};
              }
              if (this.subTypeKeysNum[type]![symbol]![pair.symbol] == null) {
                this.subTypeKeysNum[type]![symbol]![pair.symbol] = 0;
              }
              this.subTypeKeysNum[type]![symbol]![pair.symbol] =
                  this.subTypeKeysNum[type]![symbol]![pair.symbol]! + 1;
            });
          });
        }
      });
    });
  }

  // static updateSubscriptionParm(
  //     SocketProtocal widget, List<SubscriptionParm> parms) {
  //   SocketManager m = SocketManager.instance();
  //   List<SubscriptionParm> parmsTemp = m.delegateMap[widget] ?? [];
  //   if (parmsTemp.length == 0) {
  //     SocketManager.addSubscriptionParm(widget, parms);
  //     return;
  //   }
  //   List<SubscriptionParm> needUpdate = [];
  //   parmsTemp.forEach((element) {
  //     parms.forEach((newParm) {
  //       if (newParm.type == element.type) {
  //         needUpdate.add(element);
  //       }
  //     });
  //   });
  //   needUpdate.forEach((element) {
  //     parmsTemp.remove(element);
  //   });
  //   parmsTemp = [...parms, ...parmsTemp];
  //   m.delegateMap[widget] = parmsTemp;
  //   m._updateSubTypeKeyMap(widget);
  //   SocketManager.socketStart(widget);
  // }

  static disposeDelegate(SocketProtocal widget) {
    SocketManager.unsubscription(widget);
    SocketManager.instance().delegateMap.remove(widget);
  }

  static socketStart(SocketProtocal widget) {
    SocketManager m = SocketManager.instance();
    m.delegateMap[widget]?.forEach((type, parm) {
      if (parm != null) {
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
          _SocketInfo s = m._startSocket(symbol);
          m._sendMessage(symbol, s.adapter!.subscription(parm));
        });
      }
    });
  }

  static SocketManager instance() {
    if (_instance == null) {
      _instance = SocketManager._();
      HttpOverrides.global = ProxyHttpOverrides();
    }
    return _instance!;
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

  _SocketInfo _startSocket(ExchangeSymbol symbol) {
    _SocketInfo? s = socketMap[symbol];
    this.willCloseSocketMap.remove(symbol);
    if (s == null) {
      s = initSocket(symbol);
      socketMap[symbol] = s;
    }
    if (s.socket.channel?.innerWebSocket == null) {
      s.socket.start((message) => _onData(s!, message),
          (message) => _onError(s!, message), () => _onDone(s!));
    }
    return s;
  }

  _onDone(_SocketInfo socketInfo) {
    print("onDone ${socketInfo.symbol} ${socketInfo.status}");
    if (socketInfo.status == -1) {
      this.willCloseSocketMap.remove(socketInfo.symbol);
    } else {
      this.socketMap.remove(socketInfo.symbol);
    }

    if (this.delegateMap.keys.length > 0) {
      this.delegateMap.forEach((key, value) {
        key.onDone(socketInfo.symbol);
      });
    }
  }

  _onData(_SocketInfo socketInfo, dynamic message) {
    Adapter? adapter = socketInfo.adapter;
    assert(adapter != null);
    message = adapter!.gzip(message);
    message = adapter.pingPong(socketInfo.socket, message);
    SubscriptionType? type = adapter.filterDataType(message);

    if (this.delegateMap.keys.length > 0 && type != null) {
      //  print("${socketInfo.symbol} $message");
      List<SocketProtocal> widgets = [];
      this.delegateMap.forEach((key, value) {
        if (value != null && value.keys.length > 0) {
          value.forEach((type_, parm_) {
            if (type_ == type && widgets.indexOf(key) < 0) {
              widgets.add(key);
            }
          });
        }
      });

      widgets.forEach((widget) {
        // List<String> subKeys = this.subTypeKeyMap[widget]?[type] ?? [];
        List<Pair> pairs = this.delegateMap[widget]![type]!.pairs;
        List<String> subKeys = [];
        pairs.forEach((element) {
          subKeys.add(element.symbol);
        });
        BaseHQData? data;
        if (pairs.length > 0) {
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

  _sendMessage(ExchangeSymbol symbol, dynamic message) {
    _SocketInfo? s = socketMap[symbol];
    s!.socket.send(message);
  }

  // _closeSocket(ExchangeSymbol symbol) {
  //   _SocketInfo? s = socketMap[symbol];
  //   if (s != null) {
  //     s.socket.close();
  //     socketMap[symbol] = null;
  //   }
  // }

  // _startSocket(SubscriptionParm parm, void Function() ondone) {
  //   ExchangeSymbol symbol = parm.symbol;
  //   _SocketInfo? s = socketMap[symbol];
  //   if (s == null) {
  //     s = initSocket(symbol);
  //     socketMap[symbol] = s;
  //   }
  //   if (s.socket.channel?.innerWebSocket == null) {
  //     s.socket.start(s.onData, parm.onErrorFunc, ondone);
  //   }

  //   List<SubscriptionParm>? parms = s.subscriptionerParm[parm.type];
  //   if (parms == null) {
  //     parms = [];
  //   }
  //   // 做一次清理，删除重复的
  //   List<SubscriptionParm> delObj = [];
  //   for (var i = 0; i < parms.length; i++) {
  //     SubscriptionParm element = parms[i];
  //     if (element.name == parm.name) {
  //       delObj.add(element);
  //     }
  //   }
  //   if (parms.length > 0 && delObj.length > 0) {
  //     delObj.forEach((element) {
  //       parms!.remove(element);
  //     });
  //   }
  //   parms.add(parm);
  //   s.subscriptionerParm[parm.type] = parms;
  // }

  // subscription(
  //   SubscriptionParm parm,
  //   // void Function(dynamic) onData,
  //   // {void Function()? onSucc,
  //   // void Function(dynamic error)? onError,
  //   // void Function(SubscriptionParm)? onDone}
  // ) {
  //   Adapter? a = Adapter.getAdapterWith(parm.symbol);
  //   assert(a != null);
  //   // parm.subscriptionerFunc = onData;
  //   // parm.onErrorFunc = (error) {
  //   //   print(error);
  //   //   if (onError != null) {
  //   //     onError(error);
  //   //   }
  //   // };
  //   // parm.onSuccFunc = onSucc;
  //   // parm.onDone = (parm) {

  //   //   if (onDone != null) {
  //   //     onDone(parm);
  //   //   }
  //   // };
  //   this._startSocket(parm, () {
  //     print('${parm.symbol} onDone');
  //     socketMap[parm.symbol] = null;
  //     if (parm.onDone != null) {
  //       parm.onDone!();
  //     }
  //   });

  //   this._sendMessage(parm.symbol, a!.subscription(parm));
  // }

  // unsubscription(SubscriptionParm parm,
  //     [void Function()? onSucc, void Function(dynamic error)? onError]) {
  //   Adapter? a = Adapter.getAdapterWith(parm.symbol);
  //   assert(a != null);
  //   socketMap.forEach((key, value) {
  //     if (parm.symbol == key && value != null) {
  //       value.subscriptionerParm.forEach((key2, value2) {
  //         if (key2 == parm.type) {
  //           List<SubscriptionParm> delObj = [];
  //           for (var i = 0; i < value2.length; i++) {
  //             SubscriptionParm element = value2[i];
  //             if (element.name == parm.name) {
  //               delObj.add(element);
  //             }
  //           }
  //           if (delObj.length > 0) {
  //             delObj.forEach((obj) {
  //               value2.remove(obj);
  //             });
  //           }
  //           print("unsubscription ${parm.symbol}");
  //           // if (value2.length == 0) {
  //           //   value.socket.close();
  //           // }
  //           if (parm.pairs.length > 0) {
  //             this._sendMessage(parm.symbol, a!.unsubscription(parm));
  //           }
  //         }
  //       });
  //     }
  //   });
  // }
}

class _Socket {
  IOWebSocketChannel? channel;
  StreamSubscription? stream;
  _Socket(String url) {
    this.channel = IOWebSocketChannel.connect(url);
  }

  dispose() {
    print("_socket dispose ${this.channel}");
  }

  start(void Function(dynamic) onData, void Function(dynamic)? onError,
      void Function()? onDone) {
    if (this.channel != null) {
      // if (this.channel.stream. != status.abnormalClosure)
      // this.channel!.stream.
      if (this.stream == null) {
        this.stream = this.channel!.stream.listen((message) {
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
