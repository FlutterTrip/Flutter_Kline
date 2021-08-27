import 'package:flutter/material.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/localizations_manager.dart';
import '../tooltip/tooltip.dart';
import '../file_name_set/file_name_set.dart';
import '../input/text_field.dart';
import '../../manager/theme_manager.dart';
import '../button/button_com.dart';
import '../mark/mark.dart';
import '../../nav/nav.dart';

class CreateFile extends StatelessWidget {
  String text = '';
  Function(String) onPressedOK;
  CreateFile(this.onPressedOK);
  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme(context);
    TextEditingController textEditC = TextEditingController();
    textEditC.text = text;
    return PopupMenuButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      tooltip: GNLocalizations.str('new note'),
      elevation: 6,
      child: Icon(Icons.note_add_outlined,
          size: theme.fontSizeType(FontSizeType.xmd),
          color: theme.fontColorType(FontColorType.bright)),
      itemBuilder: (_) {
        return [
          GNPopupMenu(
            child: GNTextField(
              controller: textEditC,
              isi18n: true,
              hintText: 'input file name',
              onChanged: (str) {
                text = str;
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
                  if (onPressedOK != null) {
                    onPressedOK(text.trim());
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
