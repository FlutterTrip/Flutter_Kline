import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/components/chart/chart_tools.dart';
import 'package:stocks/components/chart/renders/chart_render_tools.dart';

class PaintModel extends HqChartData {
  int index = 0;
  double maxValue = 0;
  double minValue = 0;
  double sourceMaxValue = 0;
  double sourceMinValue = 0;
  int renderOffset = 0;
  final KlineChartConfig config;
  PaintModel(HqChartData data, this.config, this.renderOffset) {
    // config = _config;
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
    ma = data.ma;
  }

  String get timeStr {
    String s = DateTime.fromMillisecondsSinceEpoch(time).toString();
    return s.split(".")[0];
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
    double width = config.nowWidth.toDouble();
    double t = (double.parse(kpj) - double.parse(spj)).abs();
    double height = convertH(t);
    return Size(width, height);
  }

  Point get point {
    num x = index * config.nowWidth;
    num y = convertY(max(double.parse(spj), double.parse(kpj)));
    return Point(x - renderOffset, y);
  }

  Point get linePoint {
    return Point(index * config.nowWidth + config.nowWidth / 2 - renderOffset,
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
  Offset? _nowPoint;

  CandlePainter(List<HqChartData> _datas, KlineChartConfig _config,
      HqChartData? _lastData, Offset? _nowP, int _renderOffset) {
    _lastHqChartData = _lastData;
    _nowPoint = _nowP;
    config = _config;
    if (_datas.length > 0) {
      List<double> nums = [];
      List<double> priceNums = [];
      _datas.forEach((element) {
        if (!element.isEmpty) {
          nums.add(double.parse(element.maxPrice));
          nums.add(double.parse(element.minPrice));
          nums = [...nums, ...element.ma];

          priceNums.add(double.parse(element.maxPrice));
          priceNums.add(double.parse(element.minPrice));
        }
      });

      double maxValue = nums.reduce(max);
      double minValue = nums.reduce(min);
      double sourceMaxValue = priceNums.reduce(max);
      double sourceMinValue = priceNums.reduce(min);

      double pt = (config.paddingTop / config.height) * (maxValue - minValue);
      double pb =
          (config.paddingBottom / config.height) * (maxValue - minValue);
      maxValue += pt;
      minValue -= pb;

      int index = 0;
      _datas.forEach((element) {
        PaintModel m = PaintModel(element, _config, _renderOffset);
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
          num = maxValue - space * i;
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
      TextStyle textStyle = TextStyle(
          color: Colors.white, backgroundColor: paint.color, fontSize: 10);
      ChartRenderTools.drawText(
          canvas,
          paint,
          " ${maxPrice.toString()} ",
          Offset(element.linePoint.x.toDouble() + lineOffset,
              element.linePoint.y.toDouble() - 6),
          isFromLeftDraw: lineOffset < 0,
          textStyle: textStyle);
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

      TextStyle textStyle = TextStyle(
          color: Colors.white, backgroundColor: paint.color, fontSize: 10);

      ChartRenderTools.drawText(
          canvas,
          paint,
          " ${minPrice.toString()} ",
          Offset(element.linePoint.x.toDouble() + lineOffset,
              element.linePoint.y.toDouble() + element.lineHeight - 6),
          isFromLeftDraw: lineOffset < 0,
          textStyle: textStyle);
    }
  }

  // 最后价格线
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

      paint.color = Colors.pinkAccent;
      // print(nowPriceY);
      // ChartRenderTools.drawDash(canvas, paint, size.width, Offset(0, nowPriceY));
      ChartRenderTools.drawDash(
          canvas, paint, Offset(0, nowPriceY), Offset(size.width, nowPriceY));
      TextStyle textStyle = TextStyle(
          color: Colors.white, backgroundColor: paint.color, fontSize: 10);
      ChartRenderTools.drawText(
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

  paintAlert(Canvas canvas, Size size, Paint paint, PaintModel? model) {
    if (_nowPoint != null && model != null) {
      Offset nowP = _nowPoint!;
      double space = 8;
      Size rectSize = Size(145 + space, 64 + space);
      Offset point = Offset(
          nowP.dx >= size.width - rectSize.width
              ? nowP.dx - rectSize.width - space
              : nowP.dx,
          nowP.dy >= size.height - rectSize.height
              ? nowP.dy - rectSize.height - space
              : nowP.dy);
      Rect rect = Rect.fromLTWH(point.dx + space, point.dy + space,
          rectSize.width - space, rectSize.height - space);
      RRect outer = RRect.fromRectAndRadius(rect, Radius.circular(8.0));
      paint.color = Colors.white.withAlpha(200);
      canvas.drawRRect(outer, paint);

      List<String> titles = [
        'max: ',
        'min: ',
        'opening price: ',
        'closing price: '
      ];
      List<String> values = [
        "${double.parse(model.maxPrice)}",
        "${double.parse(model.minPrice)}",
        "${double.parse(model.kpj)}",
        "${double.parse(model.spj)}",
      ];
      Offset s = Offset(point.dx + space * 2, point.dy + space * 2);
      int index = 0;
      titles.forEach((element) {
        paint.color = config.gridConfig!.fontColor;
        int width = ChartRenderTools.drawText(canvas, paint, element, s);
        s = Offset(s.dx + width, s.dy);
        paint.color = Colors.black54;
        ChartRenderTools.drawText(canvas, paint, values[index], s);
        s = Offset(point.dx + space * 2, s.dy + 12);
        index++;
      });
    }
  }

  paintCross(Canvas canvas, Size size, Paint paint, PaintModel? selPaintModel) {
    if (_nowPoint != null) {
      paint.color = config.gridConfig!.lineColor.withAlpha(255);

      ChartRenderTools.drawCross(canvas, paint, size, _nowPoint!);
      PaintModel m = _paintModels[0];
      int digits = getDecimalDigits(m.spj);
      double valueY = ChartTools.yConvert(
          _nowPoint!.dy, size.height, m.maxValue, m.minValue);
      String text = double.parse(valueY.toStringAsFixed(digits)).toString();
      TextStyle textStyle = TextStyle(
          color: Colors.white, backgroundColor: paint.color, fontSize: 10);
      ChartRenderTools.drawText(
          canvas, paint, " $text ", Offset(0, _nowPoint!.dy - 6),
          textStyle: textStyle);
      if (selPaintModel != null) {
        bool isFromLeftDraw = false;
        if (selPaintModel.index >= _paintModels.length / 2) {
          isFromLeftDraw = true;
        }
        ChartRenderTools.drawText(canvas, paint, " ${selPaintModel.timeStr} ",
            Offset(_nowPoint!.dx, size.height - 12),
            textStyle: textStyle, isFromLeftDraw: isFromLeftDraw);
      }
    }
  }

  paintMa(Canvas canvas, Size size, Paint paint, List<Offset> points,
      ChartMAIndexConfig config) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = config.lineWidth;
    Path path = Path();
    bool isMove = false;
    points.forEach((element) {
      if (isMove) {
        path.lineTo(element.dx, element.dy);
      }
      if (element.dx != 0 && !isMove) {
        path.moveTo(element.dx, element.dy);
        isMove = true;
      }
    });
    canvas.drawPath(path, paint..color = config.lineColor);
  }

  @override
  paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipRect(rect);
    grid(canvas, size, paint);
    paint.strokeWidth = 1;
    PaintModel? selPaintModel = null;
    List<List<Offset>> maPoints = [];
    _paintModels.forEach((element) {
      if (!element.isEmpty) {
        Point p = element.point;
        Size s = element.size;
        bool isSel = false;
        if (_nowPoint != null) {
          double px = _nowPoint!.dx;
          if (px >= p.x && px <= p.x + s.width) {
            isSel = true;
            selPaintModel = element;
          }
        }
        if (isSel) {
          ChartRenderTools.drawRect(
              canvas,
              paint..color = element.color.withAlpha(20),
              Offset(p.x.toDouble(), 0),
              s.width,
              size.height);
        }
        ChartRenderTools.drawRect(canvas, paint..color = element.color,
            Offset(p.x.toDouble(), p.y.toDouble()), s.width - 1, s.height);
        ChartRenderTools.drawLine(
          canvas,
          paint,
          Offset(
              element.linePoint.x.toDouble(), element.linePoint.y.toDouble()),
          Offset(element.linePoint.x.toDouble(),
              element.linePoint.y.toDouble() + element.lineHeight),
        );
        paintMaxAndMinLabel(canvas, size, paint, element);
        if (element.ma.length > 0) {
          int maIndex = 0;
          element.ma.forEach((element1) {
            if (maPoints.length <= maIndex) {
              maPoints.add([]);
            }
            maPoints[maIndex].add(Offset(element.linePoint.x.toDouble(),
                element.convertY(element.ma[maIndex])));
            maIndex++;
          });
        }
      }
    });


    paintNowPrice(canvas, size, paint);
    paintCross(canvas, size, paint, selPaintModel);
    paintAlert(canvas, size, paint, selPaintModel);

    int index = 0;
    config.maIndexTypes.forEach((element) {
      if (maPoints.length > index) {
        paintMa(canvas, size, paint, maPoints[index], element);
      }
      index++;
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
