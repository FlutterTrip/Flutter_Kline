import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/components/alert/toast.dart';
import 'tags_view.dart';
import 'package:stocks/components/input/text_field.dart';
import 'package:stocks/components/button/button_com.dart';

class GNTagsEditView extends StatefulWidget {
  List<String> tags;
  List<GNTagModel> _tagModels = [];
  Function(String) removeTag;
  Function(String) addTag;

  GNTagsEditView({this.tags, this.removeTag, this.addTag}) {
    _tagModels = [];
    tags.forEach((element) {
      _tagModels.add(GNTagModel(element,
          numid: tags.indexOf(element), status: GNButtonStatus.off));
    });
  }

  @override
  _GNTagsEditViewState createState() => _GNTagsEditViewState();
}

class _GNTagsEditViewState extends State<GNTagsEditView> {
  GNTagModel _selTagModel;
  FocusNode _textFieldFocusNode;
  FocusNode _focusNode;
  FocusAttachment _nodeAttachment;
  bool _focused = false;
  String _text = '';
  String _lastText = '';
  TextEditingController _controller;
  @override
  initState() {
    _controller = TextEditingController();
    _textFieldFocusNode = FocusNode(onKey: _handleKeyPress);
    _focusNode = FocusNode();
    _textFieldFocusNode.addListener(_textFieldFocusNodeListener);
    _focusNode.addListener(_handleFocusChange);
    _nodeAttachment = _focusNode.attach(context, onKey: _handleKeyPress);

    super.initState();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _focused) {
      setState(() {
        _focused = _focusNode.hasFocus;
        if (_focusNode.hasFocus == false) {
          _selTagModel = null;
        }
      });
    }
  }

  List<Widget> getTags(
      List<GNTagModel> _tagModels, GNTheme theme, BuildContext context) {
    List<Widget> r = [];
    _tagModels.forEach((e) {
      GNButtonStatus s = GNButtonStatus.off;
      if (_selTagModel != null && e.numid == _selTagModel.numid) {
        s = GNButtonStatus.on;
      }
      r.add(GNTagItem(
        text: e.text,
        numid: e.numid,
        status: s,
        tagClick: (m) {
          setState(() {
            _selTagModel = m;
          });

          _textFieldFocusNode.unfocus();
          // _tagFocusNode.requestFocus();
          _focusNode.requestFocus();
          //  if (!_focused) {

          // }
          // tagClick(m);
        },
      ));
    });
    return r;
  }

  _textFieldFocusNodeListener() {
    if (_textFieldFocusNode.hasFocus) {
      setState(() {
        _selTagModel = null;
      });
      _focusNode.unfocus();
    }
  }

  KeyEventResult _handleKeyPress(FocusNode node, RawKeyEvent event) {
    _lastText = _text;
    _text = _controller.text;
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace &&
          widget.removeTag != null) {
        if (_selTagModel != null) {
          widget.removeTag(_selTagModel.text);
          FocusScope.of(context).unfocus();
        } else {
          if (_lastText == '' && widget.tags.length > 0) {
            widget.removeTag(widget.tags.last);
            FocusScope.of(context).unfocus();
          }
        }
        setState(() {
          _selTagModel = null;
        });
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _textFieldFocusNode.removeListener(_textFieldFocusNodeListener);
    _textFieldFocusNode.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme(context);
    // Radio(value: value, groupValue: groupValue, onChanged: onChanged)
    // _tagFocusNode = FocusNode();

    _nodeAttachment.reparent();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      verticalDirection: VerticalDirection.up,
      children: [
        Expanded(
          child: Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: getTags(widget._tagModels, theme, context),
              ),
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(minWidth: 50, maxWidth: 150),
          child: GNTextField(
            focusNode: _textFieldFocusNode,
            controller: _controller,
            hintText: 'Add tag',
            isi18n: true,
            // onEditingComplete: () {
            //   print('complete');
            // },
            onSubmitted: (text) {
              if (widget.tags.indexOf(text) > -1) {
                GNToastManager().showToast('repeat!',
                    toastFunc: GNToastFunc.error,
                    duration: Duration(seconds: 3));
                return;
              }
              if (widget.addTag != null) {
                widget.addTag(text);
              }
              FocusScope.of(context).unfocus();
              _controller.clear();
            },
            onChanged: (text) {},
          ),
        )
      ],
    );
  }
}
