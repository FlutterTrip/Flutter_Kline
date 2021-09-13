import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';

class VolRender extends StatelessWidget {
  final VolChartConfig config;
  final List<HqChartData> datas;
  final double maxValue;
  final double minValue;
  VolRender({Key? key, required this.config, required this.datas, required this.maxValue, required this.minValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // isComplex: true,
      // willChange: true,
      painter: VolPainter(datas, config, maxValue, minValue),
      child: Container(
        height: config.height.toDouble(),
      ),
    );
  }
}

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
  }

  Color get color {
    return double.parse(spj) > double.parse(kpj) ? config.buy : config.sell;
  }

  convertY(double source) {
    return config.height -
        ((source - minValue) / (maxValue - minValue)) * config.height;
  }

  convertH(double source) {
    return ((source - minValue) / (maxValue - minValue)) * config.height;
  }

  Size get size {
    double width = config.elementNowWidth.toDouble();
    double height = convertH(double.parse(cjl));
    return Size(width, height);
  }

  Point get point {
    num x = index * config.elementNowWidth;
    num y = convertY(double.parse(cjl));
    return Point(x, y);
  }
}

class VolPainter extends CustomPainter {
  late VolChartConfig config;
  List<HqChartData> datas = [];
  List<VolModel> _paintModels = [];

  VolPainter(List<HqChartData> _datas, VolChartConfig _config, double _maxValue,
      double _minValue) {
    config = _config;
    if (_datas.length > 0) {
      int index = 0;
      _datas.forEach((element) {
        VolModel m = VolModel(element, _config);
        m.maxValue = _maxValue;
        m.minValue = _minValue;
        m.index = index;
        _paintModels.add(m);
        index++;
      });
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
      Rect r = Rect.fromLTWH(p.x.toDouble() + 1, p.y.toDouble(), s.width - 1, s.height);
      // print(DateTime.fromMillisecondsSinceEpoch(element.time));
      canvas.drawRect(r, paint..color = element.color);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
