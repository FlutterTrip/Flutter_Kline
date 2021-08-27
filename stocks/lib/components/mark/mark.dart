import 'package:flutter/material.dart';
import 'package:stocks/components/button/button_com.dart';
import 'package:stocks/manager/theme_manager.dart';

class GNMarkPointModel {
  Color color;
  GNButtonStatus status;
  int numid;
  int order = 0;
  GNMarkPointModel(this.color, this.status, this.numid);
}

class GNMarkPointView extends StatefulWidget {
  List<Color> selColors = [];
  Function(List<Color>) markPointViewClick;
  GNMarkPointView({this.markPointViewClick, this.selColors});
  @override
  _GNMarkPointViewState createState() => _GNMarkPointViewState();
}

class _GNMarkPointViewState extends State<GNMarkPointView> {
  List<Color> get _colors {
    List<Color> r = [];
    GNTheme().markColors.forEach((element) {
      r.add(Color(element));
    });
    return r;
  }

  List<GNMarkPointModel> _models = [];
  List<Color> _selColors = [];
  @override
  void initState() {
    List selColors = widget.selColors;
    List<Color> selColorsCopy = [];
    if (selColors != null) {
      selColors.forEach((e) => selColorsCopy.add(new Color(e.value)));
    }

    _selColors = selColorsCopy;
    _colors.forEach((element) {
      GNMarkPointModel m = GNMarkPointModel(
          element, GNButtonStatus.off, _colors.indexOf(element));
      if (_selColors.indexOf(element) >= 0) {
        m.status = GNButtonStatus.on;
      }
      _models.add(m);
    });
    if (selColorsCopy.length > 0) {
      if (widget.markPointViewClick != null) {
        widget.markPointViewClick(_selColors);
      }
    }
    super.initState();
  }

  clickPoint(GNMarkPointModel model) {
    setState(() {
      if (model.status == GNButtonStatus.on) {
        model.status = GNButtonStatus.off;
        _selColors.remove(model.color);
      } else {
        if (_selColors.length < 3) {
          model.status = GNButtonStatus.on;
          _selColors.add(model.color);
        }
      }
    });
    if (widget.markPointViewClick != null) {
      widget.markPointViewClick(_selColors);
    }
  }

  Widget createPoint(GNTheme theme, GNMarkPointModel model) {
    Color hightAndHover =
        theme.fontColorType(FontColorType.bright).withAlpha(50);
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextButton(
        style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(Size(20, 20)),
            backgroundColor: MaterialStateProperty.all(
                model.status == GNButtonStatus.on
                    ? hightAndHover
                    : Colors.transparent),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(10)))),
            overlayColor: MaterialStateProperty.all(hightAndHover)),
        child: Container(
            width: 20,
            height: 20,
            child: Icon(
              Icons.circle,
              color: model.color,
              size: 15,
            )),
        onPressed: () {
          clickPoint(model);
        },
      ),
    );
  }

  List<Widget> createPoints(GNTheme theme) {
    List<Widget> r = [];
    _models.forEach((element) {
      r.add(createPoint(theme, element));
    });
    return r;
  }

  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme(context);
    // print(widget.selColors.toString());
    return Column(
      children: [Wrap(children: createPoints(theme))],
    );
  }
}

class GNMarkPoint extends StatelessWidget {
  List<Color> colors;
  GNMarkPoint(this.colors);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: CustomPaint(
      // isComplex: true,
      // willChange: true,
      size: Size(24, 6),
      painter: _MarkPainter(this.colors ?? []),
      // foregroundPainter:  _MarkPainter()
    ));
  }
}

class _MarkPainter extends CustomPainter {
  // Canvas _canvas;
  // Size _size;
  List<Color> colors;
  _MarkPainter(this.colors);
  @override
  paint(Canvas canvas, Size size) {
    double r = size.height / 2;
    Paint paint = Paint();
    Offset off = Offset(r * colors.length, r);
    this.colors.forEach((element) {
      paint.color = element;
      canvas.drawCircle(off, r, paint);
      off = Offset(off.dx - r, off.dy);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
