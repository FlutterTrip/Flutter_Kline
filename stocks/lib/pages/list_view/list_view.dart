import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/models/dataModel.dart';
import 'package:stocks/net/socket_manager.dart';
import 'package:stocks/components/search/search.dart';
import 'package:stocks/components/button/button_ wrapped.dart';
import 'package:stocks/pages/page_action.dart';

class FListView extends StatefulWidget {
  @override
  _FListViewState createState() => _FListViewState();
}

class _FListViewState extends State<FListView> {
  List<RowModel> datas = [];
  String name = "";
  @override
  void initState() {
    // print("initState");
    RowModel m = RowModel();
    m.token0 = Token("DOGE", "DOGE");
    m.token1 = Token("USDT", "USDT");
    RowModel m2 = RowModel();
    m2.token0 = Token("BNB", "BNB");
    m2.token1 = Token("USDT", "USDT");

    setState(() {
      datas = [m, m2];
      // _subscriptionData();
    });

    super.initState();
  }

  _subscriptionData() {
    SocketManager sm = SocketManager.instance();
    sm.subscription(
        SubscriptionParm(
            ExchangeSymbol.BSC, SubscriptionType.baseHQ, datas, "FListView",
            id: 66), (message) {
      BaseHQData d = message as BaseHQData;
      setState(() {
        datas.forEach((element) {
          if (element.symbol == d.symbol) {
            element.updateData(d);
          }
        });
      });
    });
  }

  List<PairRowView> getPairRowViews() {
    List<PairRowView> t = [];
    datas.forEach((element) {
      t.add(PairRowView(element));
    });
    return t;
  }

  @override
  void dispose() {
    // print('dispose');
    // SocketManager.instance().unsubscription(SubscriptionParm(ExchangeSymbol.BSC, SubscriptionType.baseHQ, datas, "FListView",
    //         id: 66));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.green,
        padding: EdgeInsets.only(top: 16, left: 8),
        constraints: BoxConstraints(maxWidth: 220),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GNText(
                  "STOCKS",
                  fontSize: GNTheme().fontSizeType(FontSizeType.lg),
                  color: GNTheme().fontColorType(FontColorType.bright),
                ),
                Expanded(
                    child: StaggeredGridView.countBuilder(
                  padding: EdgeInsets.only(top: 8, bottom: 35),
                  crossAxisCount: 2,
                  itemCount: datas.length,
                  itemBuilder: (BuildContext context, int index) =>
                      PairRowView(datas[index]),
                  staggeredTileBuilder: (index) {
                    if (datas.length == 1) {
                      return StaggeredTile.fit(2);
                    } else {
                      return StaggeredTile.fit(2);
                    }
                    // return StaggeredTile.fit(1);
                  },
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                ))
              ],
            ),
            Positioned(
                bottom: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(Icons.search),
                  color: GNTheme().fontColorType(FontColorType.bright),
                  iconSize: GNTheme().fontSizeType(FontSizeType.lg),
                  onPressed: () {
                    GKSearch(onSelected: (Pair onSel) {
                      setState(() {
                        this.datas.add(RowModel(onSel));
                        _subscriptionData();
                      });
                    }).show();
                  },
                ))
          ],
        ));
  }
}

class PairRowView extends StatelessWidget {
  final RowModel model;

  PairRowView(this.model);

  List<Row> getHqRowView() {
    List<Row> r = [];
    model.hqDatas.forEach((element) {
      r.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GNText(
            "${ExchangeManager.getExchangeModel(element.exchangeSymbol)!.name}"),
        GNText("${double.parse(element.nowPrice)} | ${element.zdf}"),
      ]));
    });
    return r;
  }

  @override
  Widget build(BuildContext context) {
    return GKWrappedButton(
        onPressed: () {
          GNPagesAction()
              .callAction(PageName.detail, FuncName.clickStock, data: [model]);
        },
        child: Row(
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GNText("${model.token0.symbol}/${model.token1.symbol}"),
                ...getHqRowView()
              ],
            ))
          ],
        ));
  }
}

class RowModel extends Pair {
  RowModel([Pair? pair]) {
    if (pair != null) {
      this.token0 = pair.token0;
      this.token1 = pair.token1;
      this.exchangeSymbol = pair.exchangeSymbol;
    }
  }

  List<BaseHQData> hqDatas = [];
  updateData(BaseHQData data) {
    bool isNewExchangeData = true;
    for (var i = 0; i < hqDatas.length; i++) {
      BaseHQData element = hqDatas[i];
      if (element.exchangeSymbol == data.exchangeSymbol) {
        hqDatas[i] = data;
        isNewExchangeData = false;
      }
    }
    if (isNewExchangeData) {
      hqDatas.add(data);
    }
  }
}
