import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'button_com.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/components/text/text.dart';

typedef GNButtonClick = void Function();

class GNButton extends StatelessWidget {
  Icon icon;
  String text;
  GNButtonClick buttonClick;
  Color color;
  GNButtonLocation location;
  GNButton(
      {this.icon,
      this.text,
      this.buttonClick,
      this.color,
      this.location = GNButtonLocation.right});
  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme(context);
    text = text == null ? '' : text;
    var radius = BorderRadius.only(
        bottomLeft: Radius.circular(15), topLeft: Radius.circular(15));
    var cedge =
        EdgeInsets.fromLTRB(text.length == 0 ? 15 : 10, 5, 5, 5);
    var tedge = EdgeInsets.fromLTRB(text.length == 0 ? 10 : 5, 0, 0, 0);
    var contentList = [
      Icon(
        icon == null ? Icons.info : icon.icon,
        size: 20,
        color: theme.fontColorType(FontColorType.bright),
      ),
      Padding(
          padding: tedge,
          child: GNText(
            text,
            color: theme.fontColorType(FontColorType.bright),
          ))
    ];
    if (location == GNButtonLocation.left) {
      radius = BorderRadius.only(
          bottomRight: Radius.circular(15),
          topRight: Radius.circular(15));
      cedge =
          EdgeInsets.fromLTRB(5, 5, text.length == 0 ? 15 : 10, 5);
      tedge = EdgeInsets.fromLTRB(0, 0, text.length == 0 ? 10 : 5, 0);
      contentList = [
        Padding(
            padding: tedge,
            child: GNText(
              text,
              color: theme.fontColorType(FontColorType.bright),
            )),
        Icon(
          icon == null ? Icons.info : icon.icon,
          size: 20,
          color: icon.color ?? theme.fontColorType(FontColorType.bright),
        )
      ];
    }

    // TextButton()

    return Positioned(
      right: location == GNButtonLocation.right ? 0 : null,
      left: location == GNButtonLocation.left ? 0 : null,
      bottom: 20,
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
                color ?? theme.bGColorType(BGColorType.normalBtn)),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
              side: BorderSide.none, borderRadius: radius)),
            overlayColor: MaterialStateProperty.all(
                theme.bGColorType(BGColorType.highlight))
            ),
          onPressed: buttonClick ?? () {},
          child: Container(
              padding: cedge,
              height: 30,
              child: Row(
                  children: contentList))),
    );
  }
}
