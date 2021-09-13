import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/components/chart/renders/chart_grid_render.dart';

class OnceChartContainer extends StatefulWidget {
  final List<HqChartData> datas;
  final List<ChartBaseConfig> configs;
  final List<ChartIndexType>? chartIndexTypes;

  OnceChartContainer(
      {Key? key,
      required this.datas,
      required this.configs,
      this.chartIndexTypes})
      : super(key: key);
  @override
  _OnceChartContainerState createState() => _OnceChartContainerState();
}

class _OnceChartContainerState extends State<OnceChartContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(OnceChartContainer oldWidget) {
    reload();
    super.didUpdateWidget(oldWidget);
  }

  reload() {
    getOnceCharts();
    // if (widget.configs.length > 0) {
    //   scrollControllerListener();
    // }
  }

  

  List<Widget> getOnceCharts() {
    List<Widget> t = [];
    if (widget.configs.length > 0) {
      widget.configs.forEach((element) {
        switch (element.type) {
          case ChartType.Grid:
            GridChartConfig config = element as GridChartConfig;
            t.add(GridRender(
              config: config,
            ));
            break;
          default:
            break;
        }
      });
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> onceCharts = getOnceCharts();
    return Stack(
      children: [
        ...onceCharts,
      ],
    );
  }
}
