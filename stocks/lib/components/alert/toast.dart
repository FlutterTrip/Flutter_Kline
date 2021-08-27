import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocks/nav/nav.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/components/icon/icon.dart';
import 'package:stocks/components/text/text.dart';

class GNToastManager {
  bool _isShowing = false;
  DateTime _startedTime;
  OverlayEntry _overlayEntry;
  static GNToastManager _m;
  GNToastModel toastModel;
  factory GNToastManager() {
    if (_m == null) {
      _m = GNToastManager._internal();
    }
    return _m;
  }

  GNToastManager._internal();

  String text;
  Icon icon;
  GNToastFunc toastFunc;
  _getIconColor(GNToastFunc toastFunc) {
    Color iconColor = GNTheme().fontColorType(FontColorType.bright);
    switch (toastFunc) {
      case GNToastFunc.warning:
        iconColor = GNTheme().fontColorType(FontColorType.warning);
        break;
      case GNToastFunc.error:
        iconColor = GNTheme().fontColorType(FontColorType.error);
        break;
      default:
        iconColor = GNTheme().fontColorType(FontColorType.bright);
    }
    return iconColor;
  }

  showToast(String text,
      {Icon icon, Duration duration, GNToastFunc toastFunc}) async {
    this.text = text;
    this.icon = icon;
    this.toastFunc = toastFunc;
    if (icon == null) this.icon = Icon(Icons.info);
    if (_overlayEntry == null) {
      _isShowing = true;
      _overlayEntry = OverlayEntry(builder: (context) {
        Icon iconTemp = Icon(this.icon.icon,
            size: 20,
            color: _getIconColor(toastFunc),
            textDirection: this.icon.textDirection,
            semanticLabel: this.icon.semanticLabel,
            key: this.icon.key);
        toastModel = GNToastModel(iconTemp, this.text, this.toastFunc);
        return Visibility(child: toastModel.widget, visible: _isShowing);
      });
      Nav().overlayState.insert(_overlayEntry);
    }
    if (_isShowing && toastModel != null) {
      Icon iconTemp = Icon(this.icon.icon,
          size: 20,
          color: _getIconColor(toastFunc),
          textDirection: this.icon.textDirection,
          semanticLabel: this.icon.semanticLabel,
          key: this.icon.key);
      toastModel.changeContent(iconTemp, this.text, this.toastFunc);
    } else {
      _isShowing = true;
      _overlayEntry.markNeedsBuild();
    }
    _startedTime = DateTime.now();
    if (duration != null) {
      await Future.delayed(duration);
      if (DateTime.now().difference(_startedTime).inMilliseconds >= 2000) {
        clostToast();
      }
    }
  }

  clostToast() {
    if (!_isShowing || _overlayEntry == null) return;
    _isShowing = false;
    _overlayEntry.markNeedsBuild();
  }

  var controllerShowAnim;
  var controllerShowOffset;
  var controllerHide;
  var opacityAnim1, showoffsetAnim, offsetAnim, opacityAnim2;
  addAnimation(OverlayState overlayState) {
    controllerShowAnim = AnimationController(
        vsync: overlayState,
        duration: Duration(milliseconds: 350));
    controllerShowOffset = AnimationController(
      vsync: overlayState,
      duration: Duration(milliseconds: 350),
    );
    controllerHide = AnimationController(
      vsync: overlayState,
      duration: Duration(milliseconds: 250),
    );

    opacityAnim1 = Tween(begin: 0.0, end: 1.0).animate(controllerShowAnim);
    showoffsetAnim = CurvedAnimation(
        parent: controllerShowOffset, curve: Curves.bounceOut);
    offsetAnim = Tween(begin: 30.0, end: 0.0).animate(controllerShowOffset);
    opacityAnim2 = Tween(begin: 1.0, end: 0.0).animate(controllerHide);
  }
}

enum GNToastFunc { standard, error, warning }

class GNToastModel with ChangeNotifier {
  GNToastFunc toastFunc = GNToastFunc.standard;
  Icon icon;
  String text;
  Widget widget;
  GNIconModel iconModel;

  GNToastModel(this.icon, this.text, [this.toastFunc = GNToastFunc.standard]) {
    this.iconModel = GNIconModel(this.icon, AnimationType.leftToRightType, 20);
    this.widget = ChangeNotifierProvider(
      create: (_) => this,
      child: GNToast(),
    );
  }

  changeContent(Icon icon, String text,
      [GNToastFunc toastFunc = GNToastFunc.standard]) {
    this.icon = icon;
    this.text = text;
    this.toastFunc = toastFunc;
    this.iconModel.changeIcon(icon);
    notifyListeners();
  }
}

class GNToast extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GNToastState();
  }
}

class _GNToastState extends State<GNToast> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var toastModel = Provider.of<GNToastModel>(context);
    GNTheme theme = GNTheme(context);
    Color bgColor = theme.bGColorType(BGColorType.highlight);
    Color textColor = theme.fontColorType(FontColorType.bright);
    switch (toastModel.toastFunc) {
      case GNToastFunc.warning:
        bgColor = theme.bGColorType(BGColorType.warning);
        textColor = theme.fontColorType(FontColorType.warning);
        break;
      case GNToastFunc.error:
        bgColor = theme.bGColorType(BGColorType.error);
        textColor = theme.fontColorType(FontColorType.error);
        break;
      default:
        bgColor = theme.bGColorType(BGColorType.highlight);
        textColor = theme.fontColorType(FontColorType.bright);
    }
    return Positioned(
        right: 0,
        top: 60,
        child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15), topLeft: Radius.circular(15)),
            child: Container(
                color: bgColor,
                height: 30,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Row(children: [
                    toastModel.iconModel.widget,
                    Padding(
                        padding: EdgeInsets.fromLTRB(2, 0, 0, 0),
                        child: GNText(
                          toastModel.text,
                          color: textColor,
                        ))
                  ]),
                ))));
  }
}
