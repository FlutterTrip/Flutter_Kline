import 'package:flutter/material.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/pages/page_action.dart';
import 'package:stocks/net/hq_net.dart';
import 'package:stocks/components/chart/chart_view.dart';
import 'package:stocks/components/chart/chart_models.dart';

class DetailView extends StatefulWidget {
  const DetailView({Key? key}) : super(key: key);

  @override
  _DetailViewState createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  Pair? _pair;
  List<HqChartData> _chartData = [];
  late List<ChartBaseConfig> _configs;
  @override
  void initState() {
    KlineChartConfig kConfig = KlineChartConfig();
    kConfig.isAutoWidth = true;
    ChartMAIndexConfig ma5 = ChartMAIndexConfig();
    ChartMAIndexConfig ma10 = ChartMAIndexConfig();
    ma10.ma = 10;
    ma10.lineColor = Colors.pinkAccent;
    ChartMAIndexConfig ma20 = ChartMAIndexConfig();
    ma20.ma = 20;
    ma20.lineColor = Colors.deepPurple;
    ChartMAIndexConfig ma60 = ChartMAIndexConfig();
    ma60.ma = 60;
    ma60.lineColor = Colors.lightBlue;
    kConfig.maIndexTypes = [ma5, ma10, ma20, ma60];

    ChartMAIndexConfig volMa5 = ChartMAIndexConfig();
    volMa5.maIndexType = ChartMAIndexType.CJL;
    ChartMAIndexConfig volMa10 = ChartMAIndexConfig();
    volMa10.maIndexType = ChartMAIndexType.CJL;
    volMa10.ma = 10;
    volMa10.lineColor = Colors.pinkAccent;
    VolChartConfig vConfig = VolChartConfig();
    vConfig.isAutoWidth = true;
    vConfig.maIndexTypes = [volMa5, volMa10];
    
    _configs = [kConfig, vConfig];

    GNPagesAction().registerAction(PageName.detail, FuncName.clickStock, widget,
        (name, funcName, {data}) {
      if (data != null && data.length > 0) {
        Pair p = data[0];
        setState(() {
          _pair = p;
          testData(p);
        });
      }
    });

    super.initState();
  }

  testData(Pair pair) {
    HqNet.getAllHqData(ExchangeSymbol.BSC, pair).then((value) {
      // print(value);
      setState(() {
        _chartData = value;
      });
    });
    // Net.get(APIManager.getApi(E, type))
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GNText(
                _pair != null ? _pair!.token0.symbol : '--',
                color: GNTheme().fontColorType(FontColorType.bright),
                fontSize: GNTheme().fontSizeType(FontSizeType.lg),
              ),
              GNText(
                _pair != null ? _pair!.token1.symbol : '--',
                color: GNTheme().fontColorType(FontColorType.gray),
                fontSize: GNTheme().fontSizeType(FontSizeType.md),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: ChartView(
                datas: _chartData,
                configs: _configs,
              ))
            ],
          )
        ],
      ),
    );
  }
}
