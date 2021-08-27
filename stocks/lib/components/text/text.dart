import 'package:flutter/material.dart';
import 'package:stocks/manager/localizations_manager.dart';
import 'package:stocks/manager/theme_manager.dart';
class GNText extends Text {
  GNText(
    String text,
    {
      bool isi18n = false,
      double? fontSize,
      Color? color,
      String? fontFamily,
      TextAlign? textAlign,
      FontWeight? fontWeight,
      double? height,
      int? maxLines,
      TextOverflow? overflow
    }
  ) : super(
    isi18n ? GNLocalizations.str(text) : text,
    maxLines: maxLines,
    overflow: overflow,
    style: TextStyle(
      height: height,
      decoration: TextDecoration.none,
      fontWeight: fontWeight == null ? FontWeight.normal : fontWeight,
      fontSize: fontSize == null ? GNTheme().fontSizeType(FontSizeType.md) : fontSize,
      color: color == null ? GNTheme().fontColorType(FontColorType.content) : color,
      fontFamily: fontFamily == null ? GNTheme().fontFamilyType(FontFamilyType.content) : fontFamily
      // fontSize: 20.0,
      // color: Color(0xFF0F4C75),
      // fontFamily: ''
    )
  );
}
