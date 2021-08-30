import 'package:flutter/material.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/models/tokenModel.dart';
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
    m.token0 = Token("BNB","BNB");
    m.token1 = Token("BTC", "BTC");
    RowModel m2 = RowModel();
    m2.token0 = Token("BNB", "BNB");
    m2.token1 = Token("ETH", "ETH");
    setState(() {
      datas = [m, m2];
    });
    SocketManager sm = SocketManager.instance();
    sm.startSocket(ExchangeSymbol.BSC, (message) {
      print(message);
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
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GNText("${model.token0.symbol}/${model.token1.symbol}"),
            GNText("成交量：1000"),
          ],
        )
      ],
    );
  }
}

class RowModel extends Pair {
  String nowPrice = '--';
}
