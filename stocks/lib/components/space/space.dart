import 'package:flutter/material.dart';

class GNSpace extends StatelessWidget {
  double height;
  double width;
  Color color;
  GNSpace({ this.height, this.width, this.color });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: this.color,
      height: this.height,
      width: this.width,
    );
  }
}
