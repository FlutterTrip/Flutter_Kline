import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stocks/components/exchange_symbols/exchange_symbols.dart';
import 'package:stocks/components/space/space.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/manager/responsive.dart';
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

class _FListViewState extends State<FListView> with SocketProtocal {
  List<RowModel> datas = [];
  String name = "";
  Map<ExchangeSymbol, SubscriptionParm?> _parmMap = {};
  @override
  void initState() {
    // print("initState");
    List<RowModel> _data = [];
    [
      // "HT/USDT",
      "DOGE/USDT",
      //"BNB/USDT", "FTM/USDT", "SOL/USDT", "EOS/USDT", "CELR/USDT", "BTC/USDT", "ETH/USDT"
    ].forEach((element) {
      RowModel m = RowModel();
      List arr = element.split('/');
      m.token0 = Token(arr[0], arr[0]);
      m.token1 = Token(arr[1], arr[1]);
      m.exchangeSymbol = [
        ExchangeSymbol.HB,
        ExchangeSymbol.BSC,
        ExchangeSymbol.OK
      ];
      _data.add(m);
    });
    setState(() {
      datas = _data;
      // _subscriptionData(null);
    });

    super.initState();

    SocketManager.registerDelegate(this);
    SocketManager.addSubscriptionParm(this, [
      SubscriptionParm(
          ExchangeSymbol.BSC, SubscriptionType.baseHQ, datas, "FListView",
          id: 66)
    ]);
    SocketManager.socketStart(this);
  }

  @override
  onData(dynamic data) {
    data as BaseHQData;
    setState(() {
      datas.forEach((element) {
        if (element.symbol == data.symbol) {
          element.updateData(data);
        }
      });
    });
  }

  _subscriptionData(ExchangeSymbol? _symbol) {
    SocketManager sm = SocketManager.instance();

    _subscriptionDataWithSymbol(ExchangeSymbol symbol) {
      List<RowModel> datas_ = [];
      datas.forEach((e) {
        if (e.exchangeSymbol.indexOf(symbol) >= 0) {
          datas_.add(e);
        }
      });
      if (datas_.length > 0) {
        SubscriptionParm parm = _parmMap[symbol] ??
            SubscriptionParm(
                symbol, SubscriptionType.baseHQ, datas_, "FListView",
                id: 66);
        parm.pairs = datas_;
        parm.subscriptionerFunc = (message) {
          BaseHQData d = message as BaseHQData;
          setState(() {
            datas.forEach((element) {
              if (element.symbol == d.symbol) {
                element.updateData(d);
              }
            });
          });
        };
        parm.onDone = () {
          _subscriptionData(parm.symbol);
        };
        sm.subscription(parm);
      }
    }

    if (_symbol == null) {
      ExchangeManager.exchanges.forEach((symbol, element) {
        _subscriptionDataWithSymbol(symbol);
      });
    } else {
      _subscriptionDataWithSymbol(_symbol);
    }
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
    super.dispose();
    print('dispose');
    SocketManager.disposeDelegate(this);
    // ExchangeManager.exchanges.forEach((symbol, element) {
    //   SubscriptionParm? p = _parmMap[symbol];
    //   if (p != null) {
    //     SocketManager.instance().unsubscription(p);
    //   }
    // });
    // _parmMap = {};
    // datas = [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: GNTheme().getZDColor(ZDColorType.up),
        padding: EdgeInsets.only(top: 16, left: 8),
        // constraints: BoxConstraints(minWidth: 220, maxWidth: 375),
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
                        SocketManager.updateSubscriptionParm(this, [
                          SubscriptionParm(ExchangeSymbol.BSC,
                              SubscriptionType.baseHQ, datas, "FListView",
                              id: 66)
                        ]);
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_status != widget.status) {
      _status = widget.status;
      _controller.reset();
      _controller.forward();
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                    : widget.status == PairZDStatus.down
                        ? GNTheme().getZDColor(ZDColorType.down)
                        : GNTheme().getZDColor(ZDColorType.normal),
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
        color: data.zdfNoUnit > 0
            ? GNTheme().getZDColor(ZDColorType.up)
            : GNTheme().getZDColor(ZDColorType.down),
      ),
      padding: EdgeInsets.all(2),
      child: GNText(data.zdf,
          fontSize: GNTheme().fontSizeType(FontSizeType.s),
          color: Colors.white),
    );
  }

  List<Widget> getHqRowView() {
    List<Widget> r = [];

    model.hqDatas.forEach((element) {
      r.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExchangeSymbols([element.exchangeSymbol]),
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
      r.add(GNSpace(
        height: 4,
      ));
    });
    return r;
  }

  @override
  Widget build(BuildContext context) {
    return GKWrappedButton(
        onPressed: () {
          GNPagesAction()
              .callAction(PageName.main, FuncName.clickStock, data: [model]);
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
                      model.token0.symbol.toUpperCase(),
                      color: GNTheme().fontColorType(FontColorType.bright),
                    ),
                    GNText(
                      model.token1.symbol.toUpperCase(),
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
