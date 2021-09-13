import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_container.dart';
import 'package:stocks/components/chart/chart_container_once.dart';
import 'package:stocks/components/chart/chart_models.dart';

class ChartView extends StatefulWidget {
  final List<HqChartData>? datas;
  final List<ChartBaseConfig> configs;
  final List<ChartIndexType>? chartIndexTypes;
  ChartView({Key? key, this.datas, this.chartIndexTypes, required this.configs})
      : super(key: key);

  @override
  _ChartViewState createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  late double _scrollViewWidth;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _scrollViewWidth = widget.configs[0].width.toDouble();
    super.initState();
  }

  @override
  void didUpdateWidget(ChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.datas != null && widget.datas!.length > 0) {
      for (var i = 0; i < widget.configs.length; i++) {
        ChartBaseConfig config = widget.configs[i];
        if (config is KlineChartConfig) {
          setState(() {
            _scrollViewWidth =
                widget.datas!.length * config.candleNowWidth * 1.0;
          });
        }
      }
    }
    // updateWidth();
  }

  updateWidth() {
    Size? size;
    if (widget.datas != null) {
      if (widget.configs.length > 0) {
        size = context.findRenderObject()?.paintBounds.size;
      }
    }

    widget.configs.forEach((element) {
      if (size != null) {
        if (element.isAutoWidth) {
          // element.width = size.width.toInt();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    
    return OrientationBuilder(
      builder: (context, o) {
    List<ChartBaseConfig> onceConfigs = [];
    List<ChartBaseConfig> configs = [];

    widget.configs.forEach((element) {
      if (element.type == ChartType.Grid) {
        onceConfigs.add(element);
      } else {
        configs.add(element);
      }
    });

    //  updateWidth();

    return Container(
      // color: Colors.green,
      child: Stack(children: [
        OnceChartContainer(
          datas: widget.datas ?? [],
          configs: onceConfigs,
        ),
        ChartContainer(
            datas: widget.datas ?? [],
            configs: configs,
            scrollController: _scrollController,
            chartIndexTypes: widget.chartIndexTypes),
        Positioned.fill(
            child: SingleChildScrollView(
                reverse: true,
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Container(
                  width: _scrollViewWidth,
                )))
      ]),
    );
      },
    );
  }
}
