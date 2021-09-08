
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';

class CandlePainter extends CustomPainter {
  late ChartConfig config;
  late List<HqChartData> datas;
  double maxValue = 0;
  double minValue = 0;

  CandlePainter(List<HqChartData> _datas, ChartConfig  _config) {
    datas = _datas;
    config = _config;
    List<double> nums = [];
    _datas.forEach((element) {
      nums.add(double.parse(element.maxPrice));
      nums.add(double.parse(element.minPrice));
    });

    maxValue = nums.reduce(max)  + _config.paddingTop;
    minValue = nums.reduce(min) + _config.paddingBottom;
    print(maxValue);
    print(minValue);
  }

  @override
  paint(Canvas canvas, Size size) {
    // print(datas.length);
    double r = size.height / 2;
    Paint paint = Paint();
    // Offset off = Offset(r * colors.length, r);
   
  }

  toY() {

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
