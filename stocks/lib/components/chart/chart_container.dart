import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/components/chart/renders/chart_kline_render.dart';

class ChartContainer extends StatefulWidget {
  final List<HqChartData> datas;
  final ChartType chartType;
  final List<SubChartType>? subChartTypes;
  final ChartConfig config;

  ChartContainer(
      {Key? key,
      required this.datas,
      required this.config,
      this.chartType = ChartType.Kline,
      this.subChartTypes})
      : super(key: key);
  @override
  _ChartContainerState createState() => _ChartContainerState();
}

class _ChartContainerState extends State<ChartContainer> {
  late double _scrollViewWidth;
  List<HqChartData> _nowDisplay = [];
  double _maxValue = 0;
  double _minValue = 0;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _scrollController.addListener(scrollControllerListener);
    _scrollViewWidth = widget.config.width.toDouble();
    super.initState();
  }

  @override
  void didUpdateWidget(ChartContainer oldWidget) {
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
    if (offset >= 0 && widget.datas.length > 0) {
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

        List<double> nums = [];
        nowDisplay.forEach((element) {
          nums.add(double.parse(element.maxPrice));
          nums.add(double.parse(element.minPrice));
        });

        double maxValue = nums.reduce(max);
        double minValue = nums.reduce(min);

        double pt = (config.paddingTop / config.height) * (maxValue - minValue);
        double pb =
            (config.paddingBottom / config.height) * (maxValue - minValue);

        maxValue += pt;
        minValue -= pb;

        setState(() {
          _nowDisplay = nowDisplay;
          _maxValue = maxValue;
          _minValue = minValue;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        KlineRender(
          config: widget.config,
          datas: _nowDisplay,
          maxValue: _maxValue,
          minValue: _minValue,
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
