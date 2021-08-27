import 'package:flutter/material.dart';
import '../manager/theme_manager.dart';
import '../manager/responsive.dart';

class Nav extends StatelessWidget with WidgetsBindingObserver {
  static Nav _m;
  Widget zeroPage;
  BuildContext context;
  OverlayState overlayState;

  factory Nav() {
    if (_m == null) {
      _m = Nav._internal();
      WidgetsBinding.instance.addObserver(_m);
    }
    return _m;
  }

  Nav._internal();

  setZeroPage(Widget zeroPage) {
    this.zeroPage = zeroPage;
  }

  push(Widget view) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => view),
    );
  }

  pushAndRemoveUntil(Widget view) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => view),
      (route) => route == null,
    );
  }

  pop({BuildContext context, Object obj}) {
    return Navigator.pop(context == null ? this.context : context, obj);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    GNThemeManager.autoChangeDarkOrLight(WidgetsBinding.instance.window.platformBrightness);
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    final _overlayState = Overlay.of(context);
    this.overlayState = _overlayState;
    GNResponsive(context);
    GNThemeManager(context);
    return Navigator(
        initialRoute: 'zeroPage',
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case 'zeroPage':
              builder = (BuildContext context) => this.zeroPage;
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        });
  }
}
