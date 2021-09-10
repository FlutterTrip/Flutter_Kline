import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_container.dart';
import 'package:stocks/components/chart/chart_models.dart';

class ChartView extends StatelessWidget {
  final List<HqChartData>? datas;
  final List<ChartBaseConfig > configs;
  final List<ChartIndexType>? chartIndexTypes;
  ChartView(
      {Key? key,
      this.datas,
      this.chartIndexTypes,
      required this.configs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, o) {
        return Container(
            child: ChartContainer(
                datas: this.datas ?? [],
                configs: this.configs,
                chartIndexTypes: this.chartIndexTypes));
      },
    );
  }
}
