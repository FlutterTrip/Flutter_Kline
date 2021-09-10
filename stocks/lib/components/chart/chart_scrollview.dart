import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/components/chart/chart_view.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/components/chart/chart_render.dart';

class ChartScrollView extends StatefulWidget {
  final List<HqChartData> datas;
  final ChartType chartType;
  final List<SubChartType>? subChartTypes;
  final ChartConfig config;

  ChartScrollView(
      {Key? key,
      required this.datas,
      required this.config,
      this.chartType = ChartType.Kline,
      this.subChartTypes})
      : super(key: key);
  @override
  _ChartScrollViewState createState() => _ChartScrollViewState();
}

class _ChartScrollViewState extends State<ChartScrollView> {
  late double _scrollViewWidth;
  List<HqChartData> _nowDisplay = [];
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _scrollController.addListener(scrollControllerListener);
    _scrollViewWidth = widget.config.width.toDouble();
    super.initState();
  }

  @override
  void didUpdateWidget(ChartScrollView oldWidget) {
    print('parent didUpdateWidget');
    reload();
    super.didUpdateWidget(oldWidget);
  }

  reload() {
    ChartConfig config = widget.config;
    int candleW = config.candleMinWidth;
    if (widget.datas.length > 0) {
      setState(() {
        _scrollViewWidth = widget.datas.length * candleW * 1.0;
      });
    }
    scrollControllerListener();
  }

  scrollControllerListener() {
    int offset = _scrollController.offset.toInt();
    if (offset >= 0) {
      ChartConfig config = widget.config;
      int candleW = config.candleMinWidth;
      int oneScreenNum = config.width ~/ candleW;

      int beforeNum = offset ~/ candleW;
      int endNum = beforeNum + oneScreenNum;
      int to = widget.datas.length - beforeNum;
      if (to > widget.datas.length) {
        to = widget.datas.length;
      }
      if (endNum < widget.datas.length) {
        Iterable<HqChartData> nowDisplay_ = widget.datas
            .getRange(widget.datas.length - 1 - beforeNum - oneScreenNum, to);
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
        ChartRender(
          datas: _nowDisplay,
          config: widget.config,
        ),
        SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Container(
              // color: Colors.redAccent.withAlpha(10),
              width: _scrollViewWidth,
              // height: 500,
            ))
      ],
    );
  }
}
