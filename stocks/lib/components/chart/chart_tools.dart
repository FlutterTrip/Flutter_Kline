import 'package:flutter/material.dart';

final double Precision = 0.5;

class ChartTools {
  static double convertY(double source, double height, double max, double min) {
    return height - ((source - min) / (max - min)) * height;
  }

  static double convertH(double source, double height, double max, double min) {
    double h = (source / (max - min)) * height;
    return h < Precision ? Precision : h;
  }

  static drawRect(
    Canvas canvas,
    Paint paint,
    Offset offset,
    double width,
    double height,
  ) {
    if (height <= 1) {
      paint.strokeWidth = height <= Precision ? Precision : height;
      drawLine(canvas, paint, offset, Offset(offset.dx + width, offset.dy));
    } else {
      Rect r = Rect.fromLTWH(offset.dx, offset.dy, width, height);
      canvas.drawRect(r, paint);
    }
  }

  static drawLine(Canvas canvas, Paint paint, Offset from, Offset to) {
      canvas.drawLine(from, to, paint);
  }

  static drawDash(Canvas canvas, Paint paint, double length, Offset from,
      {int dashWidth = 5, int dashSpace = 5}) {
    var max = length; // size获取到宽度

    double startX = from.dx;
    final space = (dashSpace + dashWidth);

    while (startX < max) {
      canvas.drawLine(
          Offset(startX, from.dy), Offset(startX + dashWidth, from.dy), paint);
      startX += space;
    }
  }

  static drawText(Canvas canvas, Paint paint, String text, Offset from,
      {TextStyle? textStyle, bool isFromLeftDraw = false}) {
    TextSpan span = TextSpan(
        text: text,
        style: textStyle ?? TextStyle(color: paint.color, fontSize: 10));
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset from_ = from;
    if (isFromLeftDraw) {
      int textOffset = tp.size.width.toInt();
      from_ = Offset(from_.dx - textOffset, from_.dy);
    }
    tp.paint(canvas, from_);
  }
}
