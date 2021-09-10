import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_scrollview.dart';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/components/text/text.dart';

class ChartView extends StatelessWidget {
  final List<HqChartData>? datas;
  final ChartType chartType;
  final ChartConfig config;
  final List<SubChartType>? subChartTypes;
  ChartView(
      {Key? key,
      this.datas,
      this.chartType = ChartType.Kline,
      this.subChartTypes,
      required this.config})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: config.width.toDouble(),
      height: config.height.toDouble(),
      child: ChartScrollView(
            datas: this.datas ?? [],
            chartType: this.chartType,
            config: this.config,
            subChartTypes: this.subChartTypes)
    );
  }
}
