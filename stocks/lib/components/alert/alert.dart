import 'package:flutter/material.dart';
import 'package:stocks/manager/localizations_manager.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/components/input/text_field.dart';
import 'package:stocks/nav/nav.dart';
import 'package:stocks/components/text/text.dart';

class GNAlert_Input {
  String? title;
  String _text = '';
  TextEditingController? textEditC;
  Function(GNAlert_Input,String)? onChanged;
  Function(GNAlert_Input,String)? onPressedOK;
  Function(GNAlert_Input)? onPressedCancel;
  GNAlert_Input(
      {this.title,
      this.onChanged,
      this.onPressedOK,
      this.onPressedCancel,
      this.textEditC});
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
            title == null ? GNLocalizations.str('warning') : title!,
            fontSize: theme.fontSizeType(FontSizeType.lg),
            color: theme.fontColorType(FontColorType.bright),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GNTextField(
                    controller: this.textEditC,
                    isi18n: true,
                    hintText: 'input file name',
                    onChanged: (text) {
                      _text = text;
                      if (this.onChanged != null) {
                        this.onChanged(this,text);
                      }
                    }),
              ],
            ),
          ),
          actions: <Widget>[
            onPressedCancel == null
                ? null
                : TextButton(
                    child: GNText(
                      'Cancel',
                      isi18n: true,
                    ),
                    onPressed: (){
                      if (this.onPressedCancel != null) this.onPressedCancel(this);
                    }),
            TextButton(
                child: GNText(
                  'OK',
                  color: theme.fontColorType(FontColorType.bright),
                  isi18n: true,
                ),
                onPressed: (){
                  if (this.onPressedOK != null) {
                    this.onPressedOK(this, _text.trim());
                  }
                }),
          ],
        );
      },
    );
  }
}

class GNAlert {
  String title;
  String content;
  Function(GNAlert) onPressedOK;
  Function(GNAlert) onPressedCancel;
  GNAlert({this.title, this.content, this.onPressedOK, this.onPressedCancel});
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
            title == null ? GNLocalizations.str('warning') : title,
            fontSize: theme.fontSizeType(FontSizeType.lg),
            color: theme.fontColorType(FontColorType.bright),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GNText(content),
              ],
            ),
          ),
          actions: <Widget>[
            onPressedCancel == null
                ? null
                : TextButton(
                    child: GNText(
                      'Cancel',
                      isi18n: true,
                    ),
                    onPressed: (){
                      if (this.onPressedCancel != null) this.onPressedCancel(this);
                    }),
            TextButton(
                child: GNText(
                  'OK',
                  color: theme.fontColorType(FontColorType.bright),
                  isi18n: true,
                ),
                onPressed: (){
                      if (this.onPressedOK != null) this.onPressedOK(this);
                    }),
          ],
        );
      },
    );
  }
}
