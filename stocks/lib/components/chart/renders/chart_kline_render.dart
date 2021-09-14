import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';

class CandleModel extends HqChartData {
  int index = 0;
  double maxValue = 0;
  double minValue = 0;
  KlineChartConfig config = KlineChartConfig();
  CandleModel(HqChartData data, KlineChartConfig _config) {
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
    double width = config.minWidth.toDouble();
    double t = (double.parse(kpj) - double.parse(spj)).abs();
    double height = convertH(t);
    return Size(width, height);
  }

  Point get point {
    num x = index * config.minWidth;
    num y = convertY(max(double.parse(spj), double.parse(kpj)));
    return Point(x, y);
  }

  Point get linePoint {
    return Point(index * config.minWidth + config.minWidth / 2,
        convertY(double.parse(maxPrice)));
  }

  double get lineHeight {
    return convertH(double.parse(maxPrice) - double.parse(minPrice));
  }
}

class CandlePainter extends CustomPainter {
  late KlineChartConfig config;
  List<CandleModel> _paintModels = [];

  CandlePainter(List<HqChartData> _datas, KlineChartConfig _config) {
    config = _config;
    if (_datas.length > 0) {
      List<double> nums = [];
      _datas.forEach((element) {
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

      int index = 0;
      _datas.forEach((element) {
        CandleModel m = CandleModel(element, _config);
        m.maxValue = maxValue;
        m.minValue = minValue;
        m.index = index;
        _paintModels.add(m);
        index++;
      });
    }
  }

  grid(Canvas canvas, Size size) {
    Paint paint = Paint();
    GridConfig gridConfig = config.gridConfig;
    paint.strokeWidth = gridConfig.lineWidth;
    paint.color = gridConfig.lineColor;

    double rowH = config.height / gridConfig.row;
    for (var i = 0; i <= gridConfig.row; i++) {
      canvas.drawLine(Offset(0, rowH * i), Offset(size.width, rowH * i), paint);
    }
  }

  @override
  paint(Canvas canvas, Size size) {
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

    if (config.gridConfig != null) {
      grid(canvas, size);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
