import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/components/chart/chart_view.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/components/chart/chart_render.dart';

class ChartScrollView extends StatefulWidget {
  final List<HqChartData>? datas;
  final ChartType chartType;
  final List<SubChartType>? subChartTypes;
  final ChartConfig? config;

  ChartScrollView(
      {Key? key,
      this.datas,
      this.config,
      this.chartType = ChartType.Kline,
      this.subChartTypes})
      : super(key: key);
  @override
  _ChartScrollViewState createState() => _ChartScrollViewState();
}

class _ChartScrollViewState extends State<ChartScrollView> {
  double _scrollViewWidth = 500;
  List<HqChartData> _nowDisplay = [];
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _scrollController.addListener(scrollControllerListener);
    ChartConfig config = widget.config ?? ChartConfig();
    int candleW = config.candleMinWidth;
    setState(() {
      _scrollViewWidth = widget.datas!.length * candleW * 1.0;
    });
    super.initState();
  }

  scrollControllerListener() {
    // int scrollView
    int offset = _scrollController.offset.toInt();
    if (offset > 0 && widget.datas != null) {
      ChartConfig config = widget.config ?? ChartConfig();
      int candleW = config.candleMinWidth;
      int oneScreenNum = 500 ~/ candleW;

      int beforeNum = offset ~/ candleW;
      int endNum = beforeNum + oneScreenNum;
      if (endNum < widget.datas!.length) {
        Iterable<HqChartData> nowDisplay_ =
            widget.datas!.getRange(beforeNum, beforeNum + oneScreenNum);
        List<HqChartData> nowDisplay = [];
        nowDisplay_.forEach((element) {
          nowDisplay.add(element);
        });
        setState(() {
          _nowDisplay = nowDisplay;
        });
      }
    }

    // print();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ChartRender(datas: _nowDisplay,),
        SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Container(
              color: Colors.redAccent.withAlpha(10),
              width: _scrollViewWidth,
              // height: 500,
            ))
      ],
    );
  }
}
