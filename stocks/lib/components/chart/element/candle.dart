import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';

class CandleModel extends HqChartData {
  int index = 0;
  double maxValue = 0;
  double minValue = 0;
  ChartConfig config = ChartConfig();
  CandleModel(HqChartData data, ChartConfig _config) {
    config = _config;
    time = data.time;
    exchangeSymbol = data.exchangeSymbol;
    symbol = data.symbol;
    nowPrice = data.nowPrice;
    zdf = data.zdf;
    kpj = data.kpj;
    spj = data.spj;
    maxPrice = data.maxPrice;
    minPrice = data.minPrice;
    cjl = data.cjl;
    cje = data.cje;
  }

  Color get color {
    return double.parse(spj) > double.parse(kpj) ? config.buy : config.sell;
  }

  convertY(double source) {
    return config.height -
        ((source - minValue) / (maxValue - minValue)) * config.height;
  }

  convertH(double source) {
    return (source / (maxValue - minValue)) * config.height;
  }

  Size get size {
    double width = config.candleMinWidth.toDouble();
    double t = (double.parse(kpj) - double.parse(spj)).abs();
    double height = convertH(t);
    return Size(width, height);
  }

  Point get point {
    num x = index * config.candleMinWidth;
    num y = convertY(max(double.parse(spj), double.parse(kpj)));
    return Point(x, y);
  }

  Point get linePoint {
    return Point(index * config.candleMinWidth + config.candleMinWidth / 2,
        convertY(double.parse(maxPrice)));
  }

  double get lineHeight {
    return convertH(double.parse(maxPrice) - double.parse(minPrice));
  }
}

class CandlePainter extends CustomPainter {
  late ChartConfig config;
  List<HqChartData> datas = [];
  List<CandleModel> _paintModels = [];

  CandlePainter(List<HqChartData> _datas, ChartConfig _config) {
    config = _config;
    if (_datas.length > 0) {
      List<double> nums = [];
      _datas.forEach((element) {
        datas.add(element);
        nums.add(double.parse(element.maxPrice));
        nums.add(double.parse(element.minPrice));
      });

      double maxValue = nums.reduce(max);
      double minValue = nums.reduce(min);

      double pt = (_config.paddingTop / _config.height) * (maxValue - minValue);
      double pb =
          (_config.paddingBottom / _config.height) * (maxValue - minValue);

      maxValue += pt;
      minValue -= pb;
      int index = 0;
      datas.forEach((element) {
        CandleModel m = CandleModel(element, _config);
        m.maxValue = maxValue;
        m.minValue = minValue;
        m.index = index;
        _paintModels.add(m);
        index++;
      });
    }
  }

  @override
  paint(Canvas canvas, Size size) {
    // print(datas.length);
    double r = size.height / 2;
    Paint paint = Paint();
    paint.strokeWidth = 1;
    _paintModels.forEach((element) {
      Point p = element.point;
      Size s = element.size;
      // print(
      // "$p|$s|${element.kpj}:${element.spj} || ${element.convertH(double.parse(element.kpj) - double.parse(element.spj))}");
      Rect r = Rect.fromLTWH(p.x.toDouble(), p.y.toDouble(), s.width, s.height);
      // print(DateTime.fromMillisecondsSinceEpoch(element.time));
      canvas.drawRect(r, paint..color = element.color);
      canvas.drawLine(
          Offset(
              element.linePoint.x.toDouble(), element.linePoint.y.toDouble()),
          Offset(element.linePoint.x.toDouble(),
              element.linePoint.y.toDouble() + element.lineHeight),
          paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
