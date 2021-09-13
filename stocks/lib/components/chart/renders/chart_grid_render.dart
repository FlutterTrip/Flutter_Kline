import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stocks/components/chart/chart_models.dart';

class GridRender extends StatelessWidget {
  final GridChartConfig config;
  // final List<HqChartData> datas;
  // final double maxValue;
  // final double minValue;
  GridRender({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // isComplex: true,
      // willChange: true,
      // size: Size(config.width.toDouble(), config.height.toDouble()),
      painter: GridPainter(config),
      child: Container(
        height: config.height.toDouble(),
      ),
    );
  }
}

class GridModel extends HqChartData {
  int index = 0;
  double maxValue = 0;
  double minValue = 0;
  GridChartConfig config = GridChartConfig();
  GridModel(HqChartData data, GridChartConfig _config) {
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
}

class GridPainter extends CustomPainter {
  late GridChartConfig config;
  List<HqChartData> datas = [];
  List<GridModel> _paintModels = [];

  GridPainter(
    GridChartConfig _config,
  ) {
    config = _config;
    // if (_datas.length > 0) {
    //   int index = 0;
    //   _datas.forEach((element) {
    //     GridModel m = GridModel(element, _config);
    //     m.maxValue = _maxValue;
    //     m.minValue = _minValue;
    //     m.index = index;
    //     _paintModels.add(m);
    //     index++;
    //   });
    // }
  }

  @override
  paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.strokeWidth = config.lineWidth;
    paint.color = config.color;

    double rowH = config.height / config.row;
    for (var i = 0; i <= config.row; i++) {
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
