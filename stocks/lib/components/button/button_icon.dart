import 'package:flutter/material.dart';
import 'package:stocks/components/tooltip/tooltip.dart';
import 'package:stocks/components/button/button_com.dart';

class GNButtonIcon extends StatelessWidget {
  Widget child;
  List<Icon> icons;
  Function onPressed;
  Function onLongPress;
  Color backgroundColor;
  Color hoverColor;
  String tooltip;
  bool isi18n;

  GNButtonIcon(this.child, this.icons,
      {this.onPressed,
      this.onLongPress,
      this.backgroundColor,
      this.hoverColor,
      this.tooltip,
      this.isi18n = false});
  @override
  Widget build(BuildContext context) {
    Widget btn = GNButton(
      Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [Expanded(child: child), ...icons]),
      onPressed: onPressed,
      onLongPress: onLongPress,
      backgroundColor: backgroundColor,
      hoverColor: hoverColor,
    );
    if (tooltip == null) {
      return btn;
    } else {
      return GNTooltip(
        isi18n: isi18n,
        child: btn,
        message: tooltip,
      );
    }
  }
}
