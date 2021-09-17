import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stocks/components/space/space.dart';
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
    List<RowModel> _data = [];
    ["DOGE/USDT", "BNB/USDT", "FTM/USDT", "SOL/USDT", "EOS/USDT", "CELR/USDT", "BTC/USDT", "ETH/USDT"].forEach((element) {
      RowModel m = RowModel();
      List arr = element.split('/');
      m.token0 = Token(arr[0], arr[0]);
      m.token1 = Token(arr[1], arr[1]);
      _data.add(m);
    });
    setState(() {
      datas = _data;
      _subscriptionData();
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
        // color: GNTheme().getZDColor(ZDColorType.up),
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

class ZDAnimation extends StatefulWidget {
  final PairZDStatus status;
  const ZDAnimation({Key? key, this.status = PairZDStatus.normal})
      : super(key: key);

  @override
  _ZDAnimationState createState() => _ZDAnimationState();
}

class _ZDAnimationState extends State<ZDAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  PairZDStatus _status = PairZDStatus.normal;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
        vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    // _animation.addStatusListener((status) {

    // });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_status != widget.status) {
      _status = widget.status;
      _controller.reset();
      _controller.forward();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      FadeTransition(
          alwaysIncludeSemantics: true,
          opacity: _animation,
          child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: widget.status == PairZDStatus.up
                    ? GNTheme().getZDColor(ZDColorType.up)
                    : widget.status == PairZDStatus.down ? GNTheme().getZDColor(ZDColorType.down) : GNTheme().getZDColor(ZDColorType.normal),
              )))
    ]);
  }
}

class PairRowView extends StatelessWidget {
  final RowModel model;
  PairRowView(this.model);

  Widget getZdfView(BaseHQData data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: data.zdfNoUnit > 0 ? GNTheme().getZDColor(ZDColorType.up) : GNTheme().getZDColor(ZDColorType.down),
      ),
      padding: EdgeInsets.all(2),
      child: GNText(data.zdf,
          fontSize: GNTheme().fontSizeType(FontSizeType.s),
          color: Colors.white),
    );
  }

  List<Row> getHqRowView() {
    List<Row> r = [];

    model.hqDatas.forEach((element) {
      ExchangeModel? exchange =
          ExchangeManager.getExchangeModel(element.exchangeSymbol);
      r.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            exchange!.logo!.length > 0
                ? Image.network(
                    exchange.logo!,
                    width: GNTheme().fontSizeType(FontSizeType.s),
                  )
                : GNText("${exchange.name}"),
            Row(
              children: [
                ZDAnimation(
                  status: element.zdStatus,
                ),
                GNSpace(
                  width: 8,
                ),
                GNText("${double.parse(element.nowPrice)}"),
                GNSpace(
                  width: 8,
                ),
                getZdfView(element)
              ],
            )
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GNText(
                      model.token0.symbol,
                      color: GNTheme().fontColorType(FontColorType.bright),
                    ),
                    GNText(
                      model.token1.symbol,
                      color: GNTheme().fontColorType(FontColorType.gray),
                      fontSize: GNTheme().fontSizeType(FontSizeType.xs),
                    ),
                  ],
                ),
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
        BaseHQData sd = hqDatas[i];
        if (data.zdfNoUnit > sd.zdfNoUnit) {
          data.zdStatus = PairZDStatus.up;
        } else if (data.zdfNoUnit < sd.zdfNoUnit) {
          data.zdStatus = PairZDStatus.down;
        } else {
          data.zdStatus = PairZDStatus.normal;
        }
        hqDatas[i] = data;
        isNewExchangeData = false;
      }
    }
    if (isNewExchangeData) {
      hqDatas.add(data);
    }
  }
}
