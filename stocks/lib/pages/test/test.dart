import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaintModel {
  Point sourcePoint = Point(0, 0);
  Point convertPoint = Point(0, 0);
  double perX = 0;
  double perY = 0;

  @override
  String toString() {
    return "$sourcePoint => $convertPoint";
  }
}

class PaintConfig {
  int get paintWidth {
    return width * pointSize;
  }

  int get paintHeight {
    return height * pointSize;
  }

  int width = 0;
  int height = 0;
  int pointSize = 5;
  double pro = 0;
  Color color = Colors.cyan;
}

class TestView extends StatefulWidget {
  const TestView({Key? key}) : super(key: key);

  @override
  _TestViewState createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  List<PaintModel> _models = [];
  PaintConfig _config = PaintConfig();

  @override
  void initState() {
    rootBundle.loadString('lib/src/map.json').then((value) {
      List source = JsonDecoder().convert(value);
      List<PaintModel> models = [];
      List<double> xL = [];
      List<double> yL = [];

      int unitL = 0;
      int unitLm = 1000;
      source.forEach((s) {
        PaintModel m = PaintModel();
        double x = s["x"];
        double y = s["y"];
        m.sourcePoint = Point(x, y);
        xL.add(x);
        yL.add(y);

        int t = max(x.toString().length, y.toString().length);
        int tm = min(x.toString().length, y.toString().length);
        unitL = t > unitL ? t : unitL;
        unitLm = unitLm < tm ? unitLm : tm;
        models.add(m);
      });

      double maxX = xL.reduce(max);
      double minX = xL.reduce(min);

      double rX = maxX - minX;

      double maxY = yL.reduce(max);
      double minY = yL.reduce(min);

      double rY = maxY - minY;

      int width = 0;
      int height = 0;
      if (rX.abs() < 1 && rY.abs() < 1) {
        int mag = pow(10, unitLm).toInt();
        print("$mag $unitLm  $unitL");
        width = (rX * mag).toInt();
        height = (rY * mag).toInt();
      }
      // 人为干预尺寸比例
      height = (height * 0.5).toInt();
      models.forEach((m) {
        m.perX = (m.sourcePoint.x - minX) / rX;
        m.perY = (m.sourcePoint.y - minY) / rY;
        double x = m.perX * width;
        double y = m.perY * height;
        m.convertPoint = Point(x.toInt(), y.toInt());
      });

      // print(models);

      _config.width = width;
      _config.height = height;
      _config.pro = width / height;
      // print("$rY $rY $minX $minY $width $height");
      setState(() {
        _models = models;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        child: Container(),
        painter: Painter(_models, _config),
      ),
    );
  }
}

class Painter extends CustomPainter {
  List<PaintModel> models = [];
  PaintConfig config = PaintConfig();

  Painter(this.models, this.config);
  @override
  void paint(Canvas canvas, Size size) {
    // print(size);
    Size size_ = Size(0, 0);
    if (size.width > size.height) {
      size_ = Size(size.width, size.width / config.pro);
    } else {
      size_ = Size(size.width, size.height / config.pro);
    }

    print("$size $size_ ${config.width} ${config.height}");
    double pointSize = config.pointSize.toDouble();
    if (models.length > 0) {
      Paint paint = Paint();
      paint.color = config.color;
      paint.strokeWidth = pointSize;
      paint.strokeCap = StrokeCap.round; 
      List<Offset> points = [];
      models.forEach((element) {
        // point
        points.add(Offset(element.perX * size_.width - pointSize, element.perY * size_.height - pointSize));
      });
      canvas.drawPoints(PointMode.points, points, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
