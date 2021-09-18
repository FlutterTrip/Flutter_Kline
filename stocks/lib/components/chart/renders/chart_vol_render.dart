import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/components/chart/chart_tools.dart';

class VolModel extends HqChartData {
  int index = 0;
  double maxValue = 0;
  double minValue = 0;
  VolChartConfig config = VolChartConfig();
  VolModel(HqChartData data, VolChartConfig _config) {
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
    cjlMa = data.cjlMa;
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
    double height = convertH(double.parse(cjl) - minValue);
    return Size(width, height);
  }

  Point get point {
    num x = index * config.nowWidth;
    num y = convertY(double.parse(cjl));
    return Point(x, y);
  }
}

class VolPainter extends CustomPainter {
  late VolChartConfig config;
  List<VolModel> _paintModels = [];

  VolPainter(List<HqChartData> _datas, VolChartConfig _config) {
    config = _config;
    if (_datas.length > 0) {
      List<double> nums = [];
      _datas.forEach((element) {
        if (!element.isEmpty) {
          nums.add(double.parse(element.cjl));
          nums = [...nums, ...element.cjlMa];
        }
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
        VolModel m = VolModel(element, _config);
        m.maxValue = maxValue;
        m.minValue = minValue;
        m.index = index;
        _paintModels.add(m);
        index++;
      });
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
    paint.strokeWidth = 1;
    List<List<Offset>> maPoints = [];
    _paintModels.forEach((element) {
      if (!element.isEmpty) {
        Point p = element.point;
        Size s = element.size;
        // print(
        // "$p|$s|${element.kpj}:${element.spj} || ${element.convertH(double.parse(element.kpj) - double.parse(element.spj))}");
        Rect r = Rect.fromLTWH(
            p.x.toDouble() + 1, p.y.toDouble(), s.width - 1, s.height);
        // print(DateTime.fromMillisecondsSinceEpoch(element.time));
        canvas.drawRect(r, paint..color = element.color);

        if (element.cjlMa.length > 0) {
          int maIndex = 0;
          element.cjlMa.forEach((element1) {
            if (maPoints.length <= maIndex) {
              maPoints.add([]);
            }
            maPoints[maIndex].add(Offset(
                element.point.x.toDouble() + s.width / 2,
                element.convertY(element.cjlMa[maIndex])));
            maIndex++;
          });
        }
      }
    });

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
