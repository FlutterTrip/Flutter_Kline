import 'package:flutter/material.dart';
import 'package:stocks/components/chart/element/candle.dart';
import 'chart_models.dart';

class ChartRender extends StatelessWidget {
  final List<HqChartData> datas;
  final ChartConfig config;
  ChartRender({Key? key, required this.datas, required this.config})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.grey,
        // height: 300,
        child: CustomPaint(
      // isComplex: true,
      // willChange: true,
      size: Size(500, 300),
      painter: CandlePainter(datas, config),
    ));
  }
}
