import 'package:flutter/material.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/exchange_manager.dart';
import 'package:stocks/models/dataModel.dart';
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
  @override
  void initState() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GNText(_pair?.symbol ?? "--"),
          _chartData.length > 0 ? ChartView(
            datas: _chartData,
            config: ChartConfig(),
            chartType: ChartType.Kline,
            subChartTypes: [],
          ) : GNText("no data")
        ],
      ),
    );
  }
}
