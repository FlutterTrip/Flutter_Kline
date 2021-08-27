import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/localizations_manager.dart';
import '../tooltip/tooltip.dart';
import '../input/text_field.dart';
import '../../manager/theme_manager.dart';
import '../button/button_com.dart';
import '../mark/mark.dart';
import '../../nav/nav.dart';

class GNPopupMenu extends PopupMenuEntry {
  double height = 30;
  Widget child = Container();
  GNPopupMenu({this.child, this.height});
  @override
  State<StatefulWidget> createState() => _GNPopupMenuState();

  @override
  bool represents(value) {
    return false;
  }
}

class _GNPopupMenuState extends State<GNPopupMenu> {
  @override
  Widget build(BuildContext context) {
    // return ClipRect(
    //   child: BackdropFilter(
    //       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    //       child: Container(
    //         // color: Colors.white,
    //           padding: EdgeInsets.only(left: 8, right: 8),
    //           height: widget.height,
    //           child: widget.child)),
    // );
    return Container(
        padding: EdgeInsets.only(left: 8, right: 8),
        height: widget.height,
        child: widget.child);
  }
}

class FileNameSet extends StatelessWidget {
  Widget child;
  String text;
  List<Color> defaultSelColors;
  List<Color> selColors = [];
  String tooltip;
  FileNameSet(
      {this.child,
      this.text,
      this.tooltip,
      this.onPressedOK,
      this.defaultSelColors});
  Function(String, List<Color>) onPressedOK;
  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme(context);
    TextEditingController textEditC = TextEditingController();
    textEditC.text = text;
    return PopupMenuButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      tooltip: tooltip,
      elevation: 6,
      child: child,
      itemBuilder: (_) {
        return [
          GNPopupMenu(
            child: GNTextField(
              controller: textEditC,
              isi18n: true,
              hintText: 'input category name',
              onChanged: (str) {
                text = str;
              },
            ),
          ),
          GNPopupMenu(
            child: GNMarkPointView(
              selColors: defaultSelColors,
              markPointViewClick: (list) {
                // print(list.toString());
                selColors = list;
              },
            ),
          ),
          GNPopupMenu(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GNButton(
                    GNText(
                      'Cancel',
                      isi18n: true,
                      color: theme.fontColorType(FontColorType.gray),
                    ),
                    hoverColor: theme.bGColorType(BGColorType.highlight),
                    onPressed: () {
                  Nav().pop(context: context);
                }),
                GNButton(
                    GNText(
                      'OK',
                      isi18n: true,
                      color: theme.fontColorType(FontColorType.bright),
                    ),
                    hoverColor: theme.bGColorType(BGColorType.highlight),
                    onPressed: () {
                  Nav().pop(context: context);
                  if (onPressedOK != null &&
                      text != null &&
                      text.trim().length > 0) {
                    onPressedOK(text, selColors);
                  }
                }),
              ],
            ),
          )
        ];
      },
    );
  }
}
