import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/components/chart/chart_tools.dart';

class PaintModel extends HqChartData {
  int index = 0;
  double maxValue = 0;
  double minValue = 0;
  double sourceMaxValue = 0;
  double sourceMinValue = 0;
  KlineChartConfig config = KlineChartConfig();
  PaintModel(HqChartData data, KlineChartConfig _config) {
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
    isEmpty = data.isEmpty;
  }

  Color get color {
    return double.parse(spj) > double.parse(kpj) ? config.buy : config.sell;
  }

  convertY(double source) {
    return ChartTools.convertY(source, config.height * 1.0, maxValue, minValue);
  }

  convertH(double source) {
    return ChartTools.convertH(source, config.height * 1.0, maxValue, minValue);
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
  List<PaintModel> _paintModels = [];
  HqChartData? _lastHqChartData;

  CandlePainter(List<HqChartData> _datas, KlineChartConfig _config,
      HqChartData? _lastData) {
    _lastHqChartData = _lastData;
    config = _config;
    if (_datas.length > 0) {
      List<double> nums = [];
      _datas.forEach((element) {
        if (!element.isEmpty) {
          nums.add(double.parse(element.maxPrice));
          nums.add(double.parse(element.minPrice));
        }
      });

      double maxValue = nums.reduce(max);
      double minValue = nums.reduce(min);
      double sourceMaxValue = maxValue;
      double sourceMinValue = minValue;

      double pt = (config.paddingTop / config.height) * (maxValue - minValue);
      double pb =
          (config.paddingBottom / config.height) * (maxValue - minValue);
      maxValue += pt;
      minValue -= pb;

      int index = 0;
      _datas.forEach((element) {
        PaintModel m = PaintModel(element, _config);
        m.maxValue = maxValue;
        m.minValue = minValue;
        m.sourceMaxValue = sourceMaxValue;
        m.sourceMinValue = sourceMinValue;
        m.index = index;
        _paintModels.add(m);
        index++;
      });
    }
  }

  int getDecimalDigits(String s) {
    List a = double.parse(s).toString().split(".");
    if (a.length > 1) {
      String x = a[1];
      return x.length;
    }
    return 0;
  }

  grid(Canvas canvas, Size size, Paint paint) {
    if (config.gridConfig != null) {
      GridConfig gridConfig = config.gridConfig!;
      paint.strokeWidth = gridConfig.lineWidth;
      paint.color = gridConfig.lineColor;

      double rowH = config.height / gridConfig.row;
      PaintModel m = _paintModels[0];
      double maxValue = m.maxValue;
      double minValue = m.minValue;

      double space = (maxValue - minValue) / gridConfig.row;
      int digits = getDecimalDigits(m.spj);
      for (var i = 0; i <= gridConfig.row; i++) {
        canvas.drawLine(
            Offset(0, rowH * i), Offset(size.width, rowH * i), paint);
        double num = 0;
        Offset textOffset = Offset(0, 0);
        if (i == 0) {
          num = maxValue;
          textOffset = Offset(0, 0);
        } else if (i == gridConfig.row) {
          num = minValue;
          textOffset =
              Offset(0, rowH * gridConfig.row - gridConfig.fontSize - 4);
        } else {
          num = space * i;
          textOffset = Offset(0, rowH * i - gridConfig.fontSize - 4);
        }

        String text = double.parse(num.toStringAsFixed(digits)).toString();

        TextSpan span = TextSpan(
            text: text,
            style: TextStyle(
                color: gridConfig.fontColor, fontSize: gridConfig.fontSize));
        TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, textOffset);
      }
    }
  }

// 最大最小值标签
  paintMaxAndMinLabel(
      Canvas canvas, Size size, Paint paint, PaintModel element) {
    int lineOffset = 10;
    if (element.index > _paintModels.length / 2) {
      lineOffset = -10;
    }
    // 最高价标志
    double maxPrice = double.parse(element.maxPrice);
    if (maxPrice >= element.sourceMaxValue) {
      canvas.drawLine(
          Offset(
              element.linePoint.x.toDouble(), element.linePoint.y.toDouble()),
          Offset(element.linePoint.x.toDouble() + lineOffset,
              element.linePoint.y.toDouble()),
          paint);

      ChartTools.drawText(
          canvas,
          paint,
          maxPrice.toString(),
          Offset(element.linePoint.x.toDouble() + lineOffset,
              element.linePoint.y.toDouble() - 6),
          isFromLeftDraw: lineOffset < 0);
    }
    double minPrice = double.parse(element.minPrice);
    // 画最低价标志
    if (minPrice <= element.sourceMinValue) {
      canvas.drawLine(
          Offset(element.linePoint.x.toDouble(),
              element.linePoint.y.toDouble() + element.lineHeight),
          Offset(element.linePoint.x.toDouble() + lineOffset,
              element.linePoint.y.toDouble() + element.lineHeight),
          paint);

      ChartTools.drawText(
          canvas,
          paint,
          minPrice.toString(),
          Offset(element.linePoint.x.toDouble() + lineOffset,
              element.linePoint.y.toDouble() + element.lineHeight - 6),
          isFromLeftDraw: lineOffset < 0);
    }
  }

  paintNowPrice(Canvas canvas, Size size, Paint paint) {
    if (_lastHqChartData != null) {
      PaintModel m = _paintModels[0];
      double nowPriceY = m.convertY(double.parse(_lastHqChartData!.spj));

      if (nowPriceY <= 0) {
        nowPriceY = 6;
      }

      if (nowPriceY >= size.height) {
        nowPriceY = size.height - 6;
      }

      paint.color = Colors.yellow;
      // print(nowPriceY);
      ChartTools.drawDash(canvas, paint, size.width, Offset(0, nowPriceY));
      TextStyle textStyle = TextStyle(
          color: Colors.white, backgroundColor: paint.color, fontSize: 10);
      ChartTools.drawText(
          canvas,
          paint,
          " ${double.parse(_lastHqChartData!.spj)} ",
          Offset(size.width - 8, nowPriceY - 6),
          textStyle: textStyle,
          isFromLeftDraw: true);
      // paint.
      // canvas.drawLine(Offset(0, nowPriceY), Offset(size.width, nowPriceY),
      //     paint..color = Colors.yellow);
    }

    // paint
  }

  @override
  paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    grid(canvas, size, paint);
    paint.strokeWidth = 1;

    _paintModels.forEach((element) {
      if (!element.isEmpty) {
        Point p = element.point;
        Size s = element.size;
        // print(
        // "$p|$s|${element.kpj}:${element.spj} || ${element.convertH(double.parse(element.kpj) - double.parse(element.spj))}");
        Rect r =
            Rect.fromLTWH(p.x.toDouble(), p.y.toDouble(), s.width, s.height);
        // print(DateTime.fromMillisecondsSinceEpoch(element.time));
        canvas.drawRect(r, paint..color = element.color);
        canvas.drawLine(
            Offset(
                element.linePoint.x.toDouble(), element.linePoint.y.toDouble()),
            Offset(element.linePoint.x.toDouble(),
                element.linePoint.y.toDouble() + element.lineHeight),
            paint);

        paintMaxAndMinLabel(canvas, size, paint, element);
      }
    });

    paintNowPrice(canvas, size, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
