import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stocks/manager/localizations_manager.dart';
import 'package:stocks/manager/theme_manager.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef Callback = void Function(String);

class GNTextField extends StatelessWidget {
  TextInputType keyboardType;
  String? hintText;
  String? nowValue;
  String? text;
  bool isi18n;
  TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  FocusNode? focusNode;

  GNTextField(
      {this.onEditingComplete,
      this.onChanged,
      this.onSubmitted,
      this.keyboardType = TextInputType.text,
      this.hintText,
      this.text,
      this.isi18n = false,
      this.controller,
      this.focusNode
      });

  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme(context);
    return Container(
        height: 30,
        child: TextField(
          focusNode: focusNode,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          controller: this.controller,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          onSubmitted: onSubmitted,
          keyboardType: this.keyboardType,
          cursorColor: theme.fontColorType(FontColorType.bright),
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: theme.fontSizeType(FontSizeType.md),
              color: theme.fontColorType(FontColorType.title)),
          decoration: InputDecoration(
            alignLabelWithHint: true,
            hoverColor: theme.bGColorType(BGColorType.highlight),
            hintStyle: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: theme.fontSizeType(FontSizeType.md),
                color: theme.fontColorType(FontColorType.bright)),
            border: InputBorder.none,
            fillColor: Colors.transparent,
            filled: true,
            hintText: isi18n && this.hintText != null ? GNLocalizations.str(this.hintText!) : this.hintText,
          ),
        ));
  }
}
