import 'package:flutter/material.dart';
import 'package:stocks/nav/nav.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/manager/symbols_manager.dart';

class GKSearch {
  Function(GKSearch)? onPressedOK;
  Function(GKSearch)? onPressedCancel;
  GKSearch({
    this.onPressedOK,
    this.onPressedCancel,
  });
  close() {
    Nav().pop();
  }

  show() {
    GNTheme theme = GNTheme();
    showDialog<void>(
      context: Nav().context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          title: GNText(
            "Search",
            fontSize: theme.fontSizeType(FontSizeType.lg),
            color: theme.fontColorType(FontColorType.bright),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // GNText(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: GNText(
                  'Cancel',
                  isi18n: true,
                ),
                onPressed: () {
                  if (this.onPressedCancel != null) this.onPressedCancel!(this);
                }),
            TextButton(
                child: GNText(
                  'OK',
                  color: theme.fontColorType(FontColorType.bright),
                  isi18n: true,
                ),
                onPressed: () {
                  if (this.onPressedOK != null) this.onPressedOK!(this);
                }),
          ],
        );
      },
    );
  }
}
