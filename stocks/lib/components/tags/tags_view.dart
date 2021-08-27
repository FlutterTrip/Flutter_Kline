import 'package:flutter/material.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/components/button/button_com.dart';

typedef TagClick = void Function(GNTagModel);
typedef TagsViewClick = void Function(List<GNTagModel>);

class GNTagModel {
  String text = '--';
  GNButtonStatus status = GNButtonStatus.off;
  int numid;
  GNTagModel(this.text, {this.status, this.numid});

  @override
  String toString() {
    return '${text} ${numid} ${status}';
  }
}

class GNTagItem extends StatelessWidget {
  String text = '--';
  Color backgroundColor;
  Color color;
  TagClick tagClick;
  GNButtonStatus status = GNButtonStatus.off;
  int numid;
  GNTagItem(
      {this.text,
      this.backgroundColor,
      this.tagClick,
      this.numid,
      this.color,
      this.status});
  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme(context);
    // backgroundColor ??= GNTheme().getTagsColor();
    return Container(
      height: theme.fontSizeType(FontSizeType.s) + 6,
      child: TextButton(
          style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size.zero),
              padding:
                  MaterialStateProperty.all(EdgeInsets.fromLTRB(15, 2, 15, 2)),
              backgroundColor: MaterialStateProperty.all(
                  status == GNButtonStatus.on
                      ? theme.fontColorType(FontColorType.bright).withAlpha(50)
                      : Colors.transparent),
              overlayColor: MaterialStateProperty.all(
                  theme.fontColorType(FontColorType.bright).withAlpha(50))),
          onPressed: tagClick != null
              ? () {
                  tagClick(GNTagModel(text, numid: numid, status: status));
                }
              : null,
          child: GNText(text,
              fontWeight: FontWeight.w300,
              color: this.color ?? theme.fontColorType(FontColorType.bright),
              fontSize: 10)),
    );
  }
}

class GNTagsViewStateless extends StatelessWidget {
  List<GNTagModel> sources = [];
  Function(GNTagModel) tagClick;
  GNTagsViewStateless({this.sources, this.tagClick});
  initItems(context) {
    List<Widget> list = [];
    sources.forEach((model) {
      list.add(GNTagItem(
          text: model.text,
          numid: model.numid,
          status: model.status,
          tagClick: tagClick));
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 3,
      runSpacing: 5,
      children: initItems(context),
    );
  }
}

class GNTagsView extends StatefulWidget {
  List<String> sourceData = [];
  List<Color> colors = [];
  TagsViewClick tagsViewClick;
  GNTagsView({this.sourceData, this.tagsViewClick, this.colors});
  Function clearSel;
  Function updateSourceData;
  Function updateSel;
  @override
  _GNTagsViewState createState() => _GNTagsViewState();
}

class _GNTagsViewState extends State<GNTagsView> {
  List<GNTagModel> _sources = [];
  @override
  initState() {
    updateData();
    super.initState();
  }

  updateData() {
    List<GNTagModel> sources = [];
    int index = 0;
    widget.sourceData.forEach((element) {
      sources
          .add(GNTagModel(element, numid: index, status: GNButtonStatus.off));
      index++;
    });
    setState(() {
      _sources = sources;
    });
  }

  tagClick(GNTagModel model) {
    setState(() {
      if (model.status == GNButtonStatus.on) {
        model.status = GNButtonStatus.off;
      } else {
        model.status = GNButtonStatus.on;
      }
    });
    List<GNTagModel> r = [];
    _sources.forEach((element) {
      if (element.status == GNButtonStatus.on) {
        r.add(element);
      }
    });
    if (r.length > 5) {
      model.status = GNButtonStatus.off;
    } else {
      widget.tagsViewClick(r);
    }
  }

  initItems(context) {
    List<Widget> list = [];
    _sources.forEach((model) {
      list.add(GNTagItem(
          text: model.text,
          numid: model.numid,
          status: model.status,
          tagClick: (_) {
            this.tagClick(model);
          }));
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clearSel == null) {
      widget.clearSel = () {
        int index = 0;
        List<int> needClear = [];
        _sources.forEach((element) {
          if (element.status == GNButtonStatus.on) {
            needClear.add(index);
          }
          index++;
        });
        if (needClear.length > 0) {
          setState(() {
            needClear.forEach((element) {
              _sources[element].status = GNButtonStatus.off;
            });
          });
        }
      };
    }
    if (widget.updateSel == null) {
      widget.updateSel = (List<GNTagModel> list) {
        List<String> needSel = [];
        list.forEach((element) {
          needSel.add(element.text);
        });

        setState(() {
          List<GNTagModel> r = [];
          _sources.forEach((element) {
            if (needSel.indexOf(element.text) >= 0) {
              element.status = GNButtonStatus.on;
              r.add(element);
            }
          });
          widget.tagsViewClick(r);
        });
      };
    }
    if (widget.updateSourceData == null) {
      widget.updateSourceData = (list) {
        widget.sourceData = list;
        updateData();
      };
    }
    return GNTagsViewStateless(
        sources: _sources,
        tagClick: (model) {
          this.tagClick(_sources[model.numid]);
        });
    return Wrap(
      spacing: 3,
      runSpacing: 5,
      children: initItems(context),
    );
  }
}
