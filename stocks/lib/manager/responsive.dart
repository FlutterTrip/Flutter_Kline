import 'package:flutter/material.dart';
import 'dart:math';

typedef ResponsiveCallback = Widget Function(GNMainViewSize);

enum GNMainViewStatus { standard, detail }
enum GNMainViewSize { big, middle, small }

abstract class GNResponsiveProtocol {
  changeMainViewStatus(GNMainViewStatus status) {}
}

class GNResponsive {
  List<GNResponsiveProtocol> widgetDelegates = [];
  GNMainViewStatus nowMainViewStatus = GNMainViewStatus.standard;
  static MediaQueryData? MQ;
  static double? Height;
  static double? Width;
  static double? MinL;
  static bool AllowFontScaling = false;

  static GNResponsive? _m;
  factory GNResponsive([BuildContext? context]) {
    if (_m == null) {
      _m = GNResponsive._internal();
    }
    if (context != null) {
      GNResponsive.MQ = MediaQuery.of(context);
      Size size = MQ!.size;
      Width = size.width;
      Height = size.height;
      MinL = min(size.width, size.height);
    }
    return _m!;
  }
  GNResponsive._internal();

  static orientation(Widget Function() portrait, Widget Function() landscape) {
    return OrientationBuilder(builder: (_, orientation) {
      Size size = MQ!.size;
      Width = size.width;
      Height = size.height;
      if (MediaQuery.of(_).orientation == Orientation.portrait) {
        return portrait();
      } else {
        return landscape();
      }
    });
  }

  static double get smScreenMinWidth => 375;
  static double get smScreenMaxWidth => 600;
  static double get midScreenMinWidth => smScreenMaxWidth;
  static double get midScreenMaxWidth => smScreenMaxWidth * 1.5;
  static double get bigScreenWidth => midScreenMaxWidth;

  static getResponsive(ResponsiveCallback nowViewSizeCallback) {
    return OrientationBuilder(builder: (_, orientation) {
      Size size = MQ!.size;
      Width = size.width;
      Height = size.height;
      GNMainViewSize s = GNMainViewSize.small;
      if (Width! <= smScreenMaxWidth) {
        s = GNMainViewSize.small;
      }
      if (Width! > smScreenMaxWidth && Width! <= midScreenMaxWidth) {
        s = GNMainViewSize.middle;
      }
      if (Width! >= bigScreenWidth) {
        s = GNMainViewSize.big;
      }
      return nowViewSizeCallback(s);
    });
  }

  static changeMainViewStatus([GNMainViewStatus mainViewStatus = GNMainViewStatus.standard]) {
    GNResponsive m = GNResponsive();
    GNMainViewStatus status = mainViewStatus;
    if (status == null) {
      status = m.nowMainViewStatus;
      switch (m.nowMainViewStatus) {
        case GNMainViewStatus.standard:
          status = GNMainViewStatus.detail;
          break;
        default:
          status = GNMainViewStatus.standard;
      }
    }
    m.nowMainViewStatus = status;
    if (m.widgetDelegates.length > 0) {
      m.widgetDelegates.forEach((element) {
        if (element != null) {
          element.changeMainViewStatus(status);
        }
      });
    }
  }

  static registerDelegate(GNResponsiveProtocol widget) {
    GNResponsive m = GNResponsive();
    m.widgetDelegates.add(widget);
  }

  static disposeDelegate(Object widget) {
    GNResponsive m = GNResponsive();
    if (m.widgetDelegates.length > 0) {
      m.widgetDelegates.remove(widget);
    }
    // m.widgetDelegates.add(widget);
  }

  static bool get isPortrait => MQ!.orientation == Orientation.portrait;
}
