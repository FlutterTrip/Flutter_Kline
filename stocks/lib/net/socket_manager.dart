import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:stocks/net/api_manager.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:stocks/manager/exchange_manager.dart';

class SocketManager {
  Map<ExchangeSymbol, _Socket?> socketMap = {};
  static SocketManager? _instance;

  SocketManager._();

  static instance() {
    if (_instance == null) {
      _instance = SocketManager._();
    }
    return _instance;
  }

  _Socket initSocket(ExchangeSymbol symbol) {
    String url = APIManager.instance().getSocketAPI(symbol);
    return _Socket(url);
  }

  startSocket(ExchangeSymbol symbol, [void Function(dynamic)? onData]) {
    _Socket? s = socketMap[symbol];
    if (s == null) {
      s = initSocket(symbol);
      socketMap[symbol] = s;
    }
    if (onData != null) {
      s.start(onData);
    }
  }

  sendMessage(ExchangeSymbol symbol, dynamic message) {
    _Socket? s = socketMap[symbol];
    if (s == null) {
      this.startSocket(symbol);
      s = socketMap[symbol];
    }
    s!.send(message);
  }

  closeSocket(ExchangeSymbol symbol) {
    _Socket? s = socketMap[symbol];
    if (s != null) {
      s.close();
      socketMap[symbol] = null;
    }
  }
}

class _Socket {
  late IOWebSocketChannel channel;
  List<void Function(dynamic)> onDatas = [];

  _Socket(String url) {
    
    Stream stream = Stream.value({
      "method": "SUBSCRIBE",
      "params": ["btcusdt@aggTrade", "btcusdt@depth"],
      "id": 1
    });
    this.channel = IOWebSocketChannel.connect(Uri.parse("$url/ws/"));
    this.channel.sink.addStream(stream);
    // IOWebSocketChannel(socket)
    // this.channel.stream.join();
    this.channel.stream.listen(this.onData, onError: (error) {
      print(error);
    });
    // this.channel.stream.
  }

  void onData(message) {
    print(message);
    if (this.onDatas.length > 0) {
      this.onDatas.forEach((element) {
        element(message);
      });
    }
  }

  start(void Function(dynamic) onData) {
    this.onDatas.add(onData);
  }

  send(dynamic message) {
    channel.sink.add(message);
  }

  close() {
    channel.sink.close(status.goingAway);
  }
}
