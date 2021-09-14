import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';



class GridPainter extends CustomPainter {
  final ChartBaseConfig config;
  List<HqChartData> datas = [];

  GridPainter(this.config);

  @override
  paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    GridConfig gridConfig = config.gridConfig;
    paint.strokeWidth = gridConfig.lineWidth;
    paint.color = gridConfig.lineColor;

    double rowH = config.height / gridConfig.row;
    for (var i = 0; i <= gridConfig.row; i++) {
      canvas.drawLine(Offset(0, rowH * i),
          Offset(size.width, rowH * i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;
}
