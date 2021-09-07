import 'package:flutter/material.dart';
import 'package:stocks/manager/theme_manager.dart';

class GKWrappedButton extends MaterialButton {
  GKWrappedButton({
    required VoidCallback onPressed,
    Widget? child,
  }) : super(
          onPressed: onPressed,
          child: child,
          color: Colors.transparent,
          elevation: 0,
          enableFeedback: false,
          hoverElevation: 0,
          hoverColor: GNTheme().bGColorType(BGColorType.highlight),
          padding: EdgeInsets.all(16),
        );
}
