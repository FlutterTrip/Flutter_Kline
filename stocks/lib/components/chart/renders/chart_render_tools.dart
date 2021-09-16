import 'package:flutter/material.dart';
import 'dart:math';

final double Precision = 0.5;

class ChartRenderTools {
  static drawCross(
    Canvas canvas,
    Paint paint,
    Size size,
    Offset point,
  ) {
    drawDash(canvas, paint, Offset(0, point.dy), Offset(size.width, point.dy) );
    drawDash(canvas, paint, Offset(point.dx, 0), Offset(point.dx, size.height));
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

  static drawDash_(Canvas canvas, Paint paint, double length, Offset from,
      {int dashWidth = 5, int dashSpace = 5}) {
    double max = length;
    double startX = from.dx;
    final space = (dashSpace + dashWidth);
    while (startX < max) {
      canvas.drawLine(
          Offset(startX, from.dy), Offset(startX + dashWidth, from.dy), paint);
      startX += space;
    }
  }

  static drawDash(Canvas canvas, Paint paint, Offset from, Offset to,
      {int dashWidth = 5, int dashSpace = 5}) {
    // double max = (from.dx - to.dx) * (from.dx - to.dx) + (from.dy - to.dy) * (from.dy - to.dy);
    double max = Point(from.dx, from.dy).distanceTo(Point(to.dx, to.dy));

    double startX = from.dx;
    double startY = from.dy;
    int space = dashSpace + dashWidth;
    int num = max ~/ space;
    double h = (to.dy - from.dy).abs();
    double w = (to.dx - from.dx).abs();
    double sh = h / num;
    double sw = w / num;
    double d = dashWidth / space;
    double endx = startX + sw * d;
    double endy = startY + sh * d;

    double nowLength = 0;
    while (nowLength < max) {
      // double distance = Point(startX, startY).distanceTo(Point(sw, sh)) - dashSpace;
      canvas.drawLine(
          Offset(startX, startY), Offset(endx, endy), paint);
      startX += sw;
      startY += sh;
      endx += sw;
      endy += sh;
      nowLength += space;
    }
  }

  static int drawText(Canvas canvas, Paint paint, String text, Offset from,
      {TextStyle? textStyle, bool isFromLeftDraw = false}) {
    TextStyle ts = textStyle ?? TextStyle(color: paint.color, fontSize: 10);
    TextSpan span = TextSpan(
        text: text,
        style: ts);
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset from_ = from;
    int textOffset = tp.size.width.toInt();
    if (isFromLeftDraw) {
      from_ = Offset(from_.dx - textOffset, from_.dy);
    }
    tp.paint(canvas, from_);
    return textOffset;
  }
}
