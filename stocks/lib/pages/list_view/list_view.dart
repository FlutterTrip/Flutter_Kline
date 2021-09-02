import 'package:flutter/material.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/models/dataModel.dart';
import 'package:stocks/net/socket_manager.dart';

class FListView extends StatefulWidget {
  @override
  _FListViewState createState() => _FListViewState();
}

class _FListViewState extends State<FListView> {
  List<RowModel> datas = [];

  @override
  void initState() {
    RowModel m = RowModel();
    m.token0 = Token("DOGE", "DOGE");
    m.token1 = Token("USDT", "USDT");
    RowModel m2 = RowModel();
    m2.token0 = Token("BNB", "BNB");
    m2.token1 = Token("USDT", "USDT");

    setState(() {
      datas = [m, m2];
    });
    SocketManager sm = SocketManager.instance();
    // Pair pair = Pair();
    // pair.token0 = Token("DOGE", "DOGE");
    // pair.token1 = Token("USDT", "USDT");
    sm.subscription(
        SubscriptionParm(ExchangeSymbol.BSC, SubscriptionType.baseHQ, datas,
            id: 66), (message) {
      print(message);
      BaseHQData d = message as BaseHQData;
      // setState(() {
      //   datas[0].nowPrice = double.parse(d.nowPrice).toStringAsFixed(4);
      //   datas[0].maxPrice = double.parse(d.maxPrice).toStringAsFixed(4);
      //   datas[0].minPrice = double.parse(d.minPrice).toStringAsFixed(4);
      // });
    });
    super.initState();
  }

  List<PairRowView> getPairRowViews() {
    List<PairRowView> t = [];
    datas.forEach((element) {
      t.add(PairRowView(element));
    });
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.green,
      constraints: BoxConstraints(maxWidth: 220),
      child: ListView(
        padding: EdgeInsets.only(top: 34),
        children: getPairRowViews(),
      ),
    );
  }
}

class PairRowView extends StatelessWidget {
  RowModel model;

  PairRowView(this.model);

  @override
  Widget build(BuildContext context) {
    return Row(
      
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GNText("${model.token0.symbol}/${model.token1.symbol}"),
            GNText("现价${model.nowPrice}"),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GNText("最高价${model.maxPrice}"),
            GNText("最低价${model.minPrice}"),
          ],
        )
      ],
    );
  }
}

class RowModel extends Pair {
  String nowPrice = '--';
  String maxPrice = '--';
  String minPrice = '--';
}
