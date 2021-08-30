import 'package:flutter/material.dart';

class GNSpace extends StatelessWidget {
  double height;
  double width;
  Color color;
  GNSpace({ this.height = 8, this.width = 0, this.color = Colors.transparent });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: this.color,
      height: this.height,
      width: this.width,
    );
  }
}
