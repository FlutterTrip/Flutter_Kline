import 'package:stocks/manager/exchange_manager.dart';
class Token {
  String? address = '--';
  String symbol = '--';
  String? name = '--';
  String shortName = '--';
  Token(this.symbol,this.shortName,[this.name, this.address]);
}

class TokenDesc extends Token {
  String? webUrl;
  String? desc;

  TokenDesc(String symbol, String shortName) : super(symbol, shortName);
}

class Currency extends Token {
  Currency(String symbol, String shortName) : super(symbol, shortName);
}
class CurrencyDesc extends TokenDesc {
  CurrencyDesc(String symbol, String shortName) : super(symbol, shortName);
}

class Pair {
  Token token0 = Token('Doge', 'Doge');
  Token token1 = Token('Bnb', 'Bnb');
  Map<String, String> otherParm = {};
  List<ExchangeSymbol> exchangeSymbol = [];
  String get symbol => '${this.token0.symbol}${this.token1.symbol}'.toLowerCase();
  @override
  String toString() {
    return this.symbol;
  }
}