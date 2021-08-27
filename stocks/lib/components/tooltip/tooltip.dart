import 'package:flutter/material.dart';
import 'package:stocks/manager/localizations_manager.dart';

class GNTooltip extends StatelessWidget {
  Widget? child;
  String message;
  bool isi18n = false;
  GNTooltip({this.child,this.message = "--", this.isi18n = false});
  @override
  Widget build(BuildContext context) {
    // GNTheme theme = GNTheme(context);
    return Tooltip(
      child: child,
      message: isi18n ? GNLocalizations.str(message) : message,
      // due to: PopupMenuButton can't custom tooltip the style
      // decoration: BoxDecoration(
      //     color: theme.bGColorType(BGColorType.background)
      //     // shape: BoxShape.circle,
      //   ),
      // textStyle: TextStyle(
      //   color: theme.fontColorType(FontColorType.bright),
      //   fontSize: theme.fontSizeType(FontSizeType.s)
      //   // backgroundColor: theme.bGColorType(BGColorType.background)
      // ),
    );
  }
}
