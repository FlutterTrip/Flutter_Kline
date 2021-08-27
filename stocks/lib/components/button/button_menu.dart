import 'package:flutter/material.dart';
import 'package:stocks/components/space/space.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'button_com.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/components/mark/mark.dart';

class GNButton_Menu extends StatelessWidget {
  String text;
  GNButtonClick onPressed;
  GNButtonClick onSecondaryTap;
  GNButtonStatus status;
  List<Color> markColors;
  Icon icon;
  GNButton_Menu(
      {this.text, this.onPressed, this.status, this.icon, this.markColors, this.onSecondaryTap});
  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme(context);
    text = text == null ? '' : text;
    // TextButton()
// F9FCFB  21BF73
    Color hightAndHover = theme.bGColorType(BGColorType.highlight);
    Widget iconWidget = icon == null ? GNSpace() : icon;
    Widget markWidget = markColors != null && markColors.length > 0
        ? GNMarkPoint(markColors)
        : GNSpace();
    return GestureDetector(
      onSecondaryTap: onSecondaryTap,
      child: TextButton(
        style: ButtonStyle(
            // backgroundColor: MaterialStateProperty.all(
            //     status == GNButtonStatus.on
            //         ? Colors.transparent
            //         : Colors.transparent),
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
              side: BorderSide.none,
            )),
            overlayColor: MaterialStateProperty.all(
                hightAndHover.withAlpha(100))
            ),
        onPressed: onPressed,
        child: Row(
          children: [
            GNSpace(
              height: 36,
              width: 2,
              color: status == GNButtonStatus.on
                  ? theme.fontColorType(FontColorType.bright)
                  : Colors.white.withAlpha(0),
            ),
            GNSpace(width: 10),
            iconWidget,
            GNText(
              text,
              fontSize: theme.fontSizeType(FontSizeType.xmd),
              textAlign: TextAlign.left,
              color: status == GNButtonStatus.on ? theme.fontColorType(FontColorType.bright):theme.fontColorType(FontColorType.title),
              fontWeight: FontWeight.w300,
            ),
            Expanded(child: GNSpace()),
            markWidget,
            GNSpace(width: 10),
          ],
        ))
    );
  }
}
