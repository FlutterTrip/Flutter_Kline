import 'package:flutter/material.dart';
import 'package:stocks/components/tooltip/tooltip.dart';
import 'package:stocks/manager/theme_manager.dart';

typedef GNButtonClick = void Function();

enum GNButtonLocation { left, right }
enum GNButtonStatus { on, off }

// class GNButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(

//     );
//   }
// }
// Tooltip()

class GNButton extends StatelessWidget {
  Widget child;
  Function onPressed;
  Function onLongPress;
  Color backgroundColor;
  Color hoverColor;
  String tooltip;
  bool isi18n;

  GNButton(this.child,
      {this.onPressed, this.backgroundColor, this.hoverColor,this.onLongPress, this.tooltip, this.isi18n = false});
  @override
  Widget build(BuildContext context) {
    Widget btn = GNButton_(
        child,
        onLongPress: onLongPress,
        onPressed: onPressed,
        backgroundColor: backgroundColor == null ? GNTheme(context).bGColorType(BGColorType.background) : backgroundColor,
        hoverColor: hoverColor == null  ?  GNTheme(context).bGColorType(BGColorType.bright).withAlpha(50) : hoverColor,
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

class GNButton_ extends TextButton {
  GNButton_(Widget child,
      {Function onPressed(), Color backgroundColor, Color hoverColor, Function onLongPress()})
      : super(
            onLongPress: onLongPress,
            child: Container(child: child, padding: EdgeInsets.only(left: 8, right: 8)),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(backgroundColor),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(5))
                )),
                overlayColor: MaterialStateProperty.all(hoverColor)),
            onPressed: onPressed);
}
