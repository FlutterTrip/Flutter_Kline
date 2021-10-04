import 'dart:convert';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/net/api_manager.dart';
import 'package:stocks/net/http.dart';
import 'package:stocks/tools/tools.dart';

class SymbolsManager {
  Map<String, Pair> pairsMap = {};
  Map<String, List<String>> searchTemp = {};
  Function? debounceSearch;
  static SymbolsManager? _instance;

  static SymbolsManager instance() {
    if (_instance == null) {
      _instance = SymbolsManager._();
      ExchangeManager.exchanges.forEach((key, value) {
        _instance?._updateSymbols(key);
      });
    }
    return _instance!;
  }

  SymbolsManager._();

  Function _debounceS = GNTools().debounce((str, result) {
    SymbolsManager m = SymbolsManager.instance();
    result(m._search(str));
  }, 500);

  static search(String str, Function(List<Pair>) result) {
    SymbolsManager.instance()._debounceS([str, result]);
  }

  List<Pair> _search(String str) {
    String searchStr = str.toLowerCase().trim();
    print("_search $str ${pairsMap.keys.length}");
    if (searchStr == "") {
      return [];
    }
    // 查看缓存里有没有之前的搜索记录
    List<String>? tempStrs = searchTemp[searchStr];
    List<String> nextKeys = [];
    if (tempStrs != null) {
      // 有记录直接先记下缓存的 keys
      nextKeys = tempStrs;
    } else {
      // 没有记录再去查单独的字母
      if (searchStr.length > 1) {
        tempStrs = searchTemp[searchStr[0]];
        if (tempStrs != null) {
          tempStrs.forEach((element) {
            if (element.indexOf(searchStr) >= 0) {
              nextKeys.add(element);
            }
          });
        }
      }
    }
    List<Pair> r = [];
    if (nextKeys.length > 0) {
      // 根据之前缓存的结果 keys 返回数据模型列表

      nextKeys.forEach((element) {
        r.add(pairsMap[element]!);
      });
      return r;
    }

    // 当没有在缓存中查到时候，进行源数据查找

    pairsMap.forEach((key, value) {
      if (key.indexOf(searchStr) >= 0) {
        nextKeys.add(key);
        r.add(value);
      }
    });
    if (searchTemp.length >= 20) {
      // 缓存最多保存 20 个，超过就要删除最小的那个
      String minListKey = "";
      int num = pairsMap.length;
      searchTemp.forEach((key, value) {
        if (value.length < num) {
          num = value.length;
          minListKey = key;
        }
      });
      searchTemp.remove(minListKey);
    }
    searchTemp[searchStr] = nextKeys;
    return r;
  }

  _updateSymbols(ExchangeSymbol symbol) {
    String baseUrl = APIManager.getApi(symbol, apiType.baseUrl)!;
    String apiPath = APIManager.getApi(symbol, apiType.symbols)!;

    Net.get("$baseUrl$apiPath").then((value) {
      dynamic obj = JsonDecoder().convert(value.toString());
      _analysisSourceSymbols(symbol, obj);
    });
  }

  _analysisSourceSymbols(ExchangeSymbol symbol, Map data) {
    switch (symbol) {
      case ExchangeSymbol.BSC:
        _analysisBSC(data);
        break;
      case ExchangeSymbol.HB:
        _analysisHB(data);
        break;
      case ExchangeSymbol.OK:
        _analysisOK(data);
        break;
      default:
        break;
    }
  }

  _analysisOK(Map data) {
    ExchangeSymbol symbol = ExchangeSymbol.OK;
    List l = data["data"];
    l.forEach((element) {
      if (element["state"] == "live") {
        String s =
            "${element["baseCcy"].toString().toLowerCase()}${element["quoteCcy"].toString().toLowerCase()}";
        Pair? p = pairsMap[s];
        if (p == null) {
          Pair pair = Pair();
          pair.exchangeSymbol = [symbol];
          pair.token0 = Token(element["baseCcy"], element["baseCcy"]);
          pair.token1 = Token(element["quoteCcy"], element["quoteCcy"]);
          pair.otherParm["instId"] = element["instId"].toString();
          pairsMap[s] = pair;
        } else {
          p.otherParm["instId"] = element["instId"].toString();
          p.exchangeSymbol.remove(symbol);
          p.exchangeSymbol.add(symbol);
        }
      }
    });
  }

  _analysisHB(Map data) {
    ExchangeSymbol symbol = ExchangeSymbol.HB;
    List l = data["data"];
    l.forEach((element) {
      if (element["state"] == "online") {
        String s = element["symbol"].toString().toLowerCase();
        Pair? p = pairsMap[s];
        if (p == null) {
          Pair pair = Pair();
          pair.exchangeSymbol = [symbol];
          pair.token0 =
              Token(element["base-currency"], element["base-currency"]);
          pair.token1 =
              Token(element["quote-currency"], element["quote-currency"]);
          pairsMap[s] = pair;
        } else {
          p.exchangeSymbol.remove(symbol);
          p.exchangeSymbol.add(symbol);
        }
      }
    });
  }

  _analysisBSC(Map data) {
    ExchangeSymbol symbol = ExchangeSymbol.BSC;
    List l = data["symbols"];
    l.forEach((element) {
      if (element["status"] == "TRADING") {
        String s = element["symbol"].toString().toLowerCase();
        Pair? p = pairsMap[s];
        if (p == null) {
          Pair pair = Pair();
          pair.exchangeSymbol = [symbol];
          pair.token0 = Token(element["baseAsset"], element["baseAsset"]);
          pair.token1 = Token(element["quoteAsset"], element["quoteAsset"]);
          pairsMap[s] = pair;
        } else {
          p.exchangeSymbol.remove(symbol);
          p.exchangeSymbol.add(symbol);
        }
      }
    });
  }
}
