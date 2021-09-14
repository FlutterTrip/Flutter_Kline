import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/components/chart/renders/chart_kline_render.dart';
import 'package:stocks/components/chart/renders/chart_vol_render.dart';

class ChartContainer extends StatefulWidget {
  final List<ChartBaseConfig> configs;
  final List<HqChartData> datas;
  const ChartContainer({Key? key, required this.configs, required this.datas})
      : super(key: key);

  @override
  _ChartContainerState createState() => _ChartContainerState();
}

class _ChartContainerState extends State<ChartContainer> {
  double _scrollContentWidth = 500;
  List<HqChartData> _nowDisplayData = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(scrollControllerListener);
    super.initState();
  }

  @override
  void didUpdateWidget(ChartContainer oldWidget) {
    if (widget.configs.length > 0 && widget.datas.length > 0) {
      Object config = widget.configs[0];
      if (config is KlineChartConfig || config is VolChartConfig) {
        config as KlineChartConfig;
        setState(() {
          _scrollContentWidth = widget.datas.length * config.nowWidth * 1.0;
        });
      }
      scrollControllerListener();
    }
   
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  scrollControllerListener() {
    int offset = _scrollController.offset.toInt();
    if (offset >= 0 && widget.datas.length > 0 && widget.configs.length > 0) {
      Object config = widget.configs[0];
      Size? size = context.findRenderObject()?.paintBounds.size;
     
      int elementW = 0;
      if (config is KlineChartConfig || config is VolChartConfig) {
        config as KlineChartConfig;
        elementW = config.nowWidth;
      }

      config as ChartBaseConfig;

      int width = size == null ? config.width : size.width.toInt();

      int oneScreenNum = width ~/ elementW;
      int rightNum = offset ~/ elementW;
      int fromNum = rightNum + oneScreenNum;
      if (fromNum > widget.datas.length) {
        // 一个屏幕显示的数量超出总共的数量
        fromNum = widget.datas.length;
      }
      int to = widget.datas.length - rightNum;
      if (fromNum <= widget.datas.length) {
        List<HqChartData> nowDisplay = [];
        nowDisplay = widget.datas.sublist(widget.datas.length - fromNum, to);
        setState(() {
          _nowDisplayData = nowDisplay;
        });
      }
    }
  }

  Widget getReanderView(ChartBaseConfig config) {
    if (widget.datas.length > 0) {
      switch (config.type) {
        case ChartType.Kline:
          return CustomPaint(
            child: Container(
              height: config.height.toDouble(),
            ),
            painter: CandlePainter(_nowDisplayData, config as KlineChartConfig),
          );
        case ChartType.Vol:
          return CustomPaint(
            child: Container(
              height: config.height.toDouble(),
            ),
            painter: VolPainter(_nowDisplayData, config as VolChartConfig),
          );
        default:
          return Container();
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> renderView = [];
    widget.configs.forEach((config) => renderView.add(getReanderView(config)));

    return Stack(
      children: [
        Column(
          children: renderView,
        ),
        Positioned.fill(
            child: SingleChildScrollView(
                reverse: true,
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Container(
                  width: _scrollContentWidth,
                )))
      ],
    );
  }
}
