import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/components/chart/renders/chart_kline_render.dart';
import 'package:stocks/components/chart/renders/chart_vol_render.dart';

class ChartContainer extends StatefulWidget {
  final List<HqChartData> datas;
  final ChartType chartType;
  final List<ChartBaseConfig> configs;
  final List<ChartIndexType>? chartIndexTypes;

  ChartContainer(
      {Key? key,
      required this.datas,
      required this.configs,
      this.chartType = ChartType.Kline,
      this.chartIndexTypes})
      : super(key: key);
  @override
  _ChartContainerState createState() => _ChartContainerState();
}

class _ChartContainerState extends State<ChartContainer> {
  late double _scrollViewWidth;
  List<HqChartData> _nowDisplay = [];
  Map<ChartType, List<double>> _maxAndMinTemp = {};

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _scrollController.addListener(scrollControllerListener);
    _scrollViewWidth = widget.configs[0].width.toDouble();
    super.initState();
  }

  @override
  void didUpdateWidget(ChartContainer oldWidget) {
    reload();
    super.didUpdateWidget(oldWidget);
  }

  reload() {
    if (widget.configs.length > 0) {
      scrollControllerListener();
    }
  }

  analysisKline(int offset, KlineChartConfig config) {
    int candleW = config.candleNowWidth;
    int oneScreenNum = config.width ~/ candleW;
    int rightNum = offset ~/ candleW;
    int fromNum = rightNum + oneScreenNum;
    if (fromNum > widget.datas.length) {
      // 一个屏幕显示的数量超出总共的数量
      fromNum = widget.datas.length;
    }
    int to = widget.datas.length - rightNum;
    if (fromNum <= widget.datas.length) {
      List<HqChartData> nowDisplay = [];
      nowDisplay = widget.datas.sublist(widget.datas.length - fromNum, to);
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
        _maxAndMinTemp[ChartType.Kline] = [maxValue, minValue];
      });
    }
  }

  analysisVol(int offset, VolChartConfig config) {
    
    int candleW = config.elementNowWidth;
    int oneScreenNum = config.width ~/ candleW;
    int rightNum = offset ~/ candleW;
    int fromNum = rightNum + oneScreenNum;
    if (fromNum > widget.datas.length) {
      // 一个屏幕显示的数量超出总共的数量
      fromNum = widget.datas.length;
    }
    int to = widget.datas.length - rightNum;
    if (fromNum <= widget.datas.length) {
      List<HqChartData> nowDisplay = [];
      nowDisplay = widget.datas.sublist(widget.datas.length - fromNum, to);
      List<double> nums = [];
      nowDisplay.forEach((element) {
        nums.add(double.parse(element.cjl));
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
        _maxAndMinTemp[ChartType.Vol] = [maxValue, minValue];
      });
    }
  }

  scrollControllerListener() {
    int offset = _scrollController.offset.toInt();
    if (offset >= 0 && widget.datas.length > 0) {
      widget.configs.forEach((element) {
        switch (element.type) {
          case ChartType.Kline:
            analysisKline(offset, element as KlineChartConfig);
            break;
          case ChartType.Vol:
            analysisVol(offset, element as VolChartConfig);
            break;
          default:
            break;
        }
      });
    }
  }

  List<Widget> getRenders() {
    List<Widget> t = [];
    if (widget.configs.length > 0) {
      widget.configs.forEach((element) {
        Size? size = context.findRenderObject()?.paintBounds.size;
        if (size != null) {
          if (element.isAutoWidth) {
            element.width = size.width.toInt();
          }
          // if (config.isAutoHeight) {
          //   config.height = size.height.toInt();
          // }
        }
        List<double> maxMinList = _maxAndMinTemp[element.type] ?? [0, 0];
        double _maxValue = maxMinList[0];
        double _minValue = maxMinList[1];
        switch (element.type) {
          case ChartType.Kline:
            KlineChartConfig config = element as KlineChartConfig;
            if (widget.datas.length > 0) {
              setState(() {
                _scrollViewWidth =
                    widget.datas.length * config.candleNowWidth * 1.0;
              });
            }

            t.add(KlineRender(
              config: config,
              datas: _nowDisplay,
              maxValue: _maxValue,
              minValue: _minValue,
            ));
            break;
          case ChartType.Vol:
            VolChartConfig config = element as VolChartConfig;

            t.add(VolRender(
              config: config,
              datas: _nowDisplay,
              maxValue: _maxValue,
              minValue: _minValue,
            ));
            break;
          default:
            break;
        }
      });
      // setState(() {
      //   _renders = t;
      // });
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: getRenders(),
        ),
        Positioned.fill(
            child: SingleChildScrollView(
                reverse: true,
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Container(
                  width: _scrollViewWidth,
                )))
      ],
    );
  }
}
