import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/animation.dart';

enum AnimationType {
  defaultType,
  breatheType,
  rightToLeftType,
  leftToRightType,
  topToBottomType,
  bottomToTopType,
}

class GNIconModel with ChangeNotifier {
  double defaultSize = 30.0;
  Icon icon;
  Icon lastIcon;
  double width;
  double height;
  Widget widget;
  AnimationType animationType;
  GNIconModel(this.icon, this.animationType, [double defaultSize = 30]) {
    this.defaultSize = defaultSize;
    if (icon.size == null) {
      icon = Icon(icon.icon,
          size: defaultSize,
          color: icon.color,
          textDirection: icon.textDirection,
          semanticLabel: icon.semanticLabel,
          key: icon.key);
    }
    lastIcon = icon;
    this.width = this.lastIcon.size;
    this.height = this.lastIcon.size;
    this.widget = ChangeNotifierProvider(
      create: (_) => this,
      child: GNIcon(),
    );
  }

  void changeIcon(Icon icon) {
    this.animationType = animationType;
    if (icon.size == null) {
      icon = Icon(icon.icon,
          size: defaultSize,
          color: icon.color,
          textDirection: icon.textDirection,
          semanticLabel: icon.semanticLabel,
          key: icon.key);
    }
    this.lastIcon = this.icon;
    this.icon = icon;
    this.width = this.lastIcon.size;
    this.height = this.lastIcon.size;
    notifyListeners();
  }
}

class GNIcon extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GNIconState();
  }
}

class _GNIconState extends State<GNIcon> with TickerProviderStateMixin {
  ScrollController _scrollController;
  initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0);
  }

  Icon icon;
  Icon lastIcon;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose(); // 资源释放
  }

  @override
  Widget build(BuildContext context) {
    var iconModel = Provider.of<GNIconModel>(context);
    this.icon = iconModel.icon;
    this.lastIcon = iconModel.lastIcon;
    switch (iconModel.animationType) {
      case AnimationType.leftToRightType:
        return getLeftToRightWidget(iconModel);
        break;
      case AnimationType.rightToLeftType:
        return getRightToLeftWidget(iconModel);
        break;
      case AnimationType.topToBottomType:
        return getTopToBottomWidget(iconModel);
        break;
      case AnimationType.bottomToTopType:
        return getBottomToTopWidget(iconModel);
        break;
      default:
        return iconModel.icon;
    }
  }

  animationAction(GNIconModel model) {
    if (model.lastIcon != model.icon) {
      _scrollController.jumpTo(0);
      _scrollController.animateTo(model.width,
          duration: Duration(milliseconds: 150), curve: Curves.linear);
    }
  }

  getLeftToRightWidget(GNIconModel model) {
    final widget = getSingleChildScrollView(model, Axis.horizontal);
    animationAction(model);
    return widget;
  }

  getRightToLeftWidget(GNIconModel model) {
    final widget =
        getSingleChildScrollView(model, Axis.horizontal, reverse: true);
    animationAction(model);
    return widget;
  }

  getBottomToTopWidget(GNIconModel model) {
    final widget = getSingleChildScrollView(model, Axis.vertical);
    animationAction(model);
    return widget;
  }

  getTopToBottomWidget(GNIconModel model) {
    final widget =
        getSingleChildScrollView(model, Axis.vertical, reverse: true);
    animationAction(model);
    return widget;
  }

  getSingleChildScrollView(GNIconModel model, Axis scrollDirection,
      {bool reverse = false}) {
    List<Widget> list = [this.lastIcon, this.icon];
    if (reverse) {
      list = [this.icon, this.lastIcon];
    }
    Widget child = Row(
      children: list,
    );
    if (scrollDirection == Axis.vertical) {
      child = Column(
        children: list,
      );
    }
    return Container(
      width: model.width,
      height: model.height,
      child: SingleChildScrollView(
          reverse: reverse,
          controller: _scrollController,
          scrollDirection: scrollDirection,
          child: child),
    );
  }
}
