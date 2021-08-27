import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stocks/components/button/button_icon.dart';
import 'package:stocks/components/button/button_com.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/manager/theme_manager.dart';

enum MenuListItemType { rss, file, empty }

class MenuListItem {
  MenuListItem(
      {this.title,
      this.type = MenuListItemType.rss,
      this.isExpanded = false,
      this.isWillRemove = false,
      this.location,
      this.subItems});
  List<int> location;
  String id;
  String imgUrl;
  String title;
  MenuListItemType type;
  bool isExpanded;
  List<MenuListItem> subItems;
  bool isWillRemove;
  MenuListItem copy() {
    MenuListItem t = MenuListItem();
    t.location = this.location;
    t.id = this.id;
    t.imgUrl = this.imgUrl;
    t.title = this.title;
    t.type = this.type;
    t.isExpanded = this.isExpanded;
    t.subItems = this.subItems;
    t.isWillRemove = this.isWillRemove;
    return t;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '${title}${type}${location}';
  }
}

class MenuView extends StatefulWidget {
  @override
  _MenuViewState createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  List<MenuListItem> _data = [
    MenuListItem(title: '数字尾巴', location: [0]),
    MenuListItem(title: 'code', type: MenuListItemType.file, location: [
      1
    ], subItems: [
      MenuListItem(title: 'iOS', location: [1, 0]),
      MenuListItem(title: 'React', location: [1, 1]),
    ]),
    MenuListItem(title: '少数派', location: [2]),
    MenuListItem(title: 'other', location: [3]),
  ];
  MenuListItem _dragEnterItem;
  MenuListItem _nowDragItem;
  MenuListItem _emptyItem;

  List<Widget> getSubList(List<MenuListItem> list, int index) {
    List<Widget> subList = [];
    list.forEach((item) {
      int index2 = list.indexOf(item);
      if (item.type == MenuListItemType.empty) {
        subList.add(createEmptyItem(item, index + index2));
      } else {
        subList.add(createDragItem(item, index + index2));
      }
    });
    return subList;
  }

  MaterialSlice getSubContent(MenuListItem item, int index) {
    List<Widget> subItems = [];
    subItems.add(createDragItem(item, index));
    Widget subBody = AnimatedCrossFade(
      firstChild: Container(height: 0.0),
      secondChild: Container(
        margin: EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: getSubList(item.subItems, index),
        ),
      ),
      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.fastOutSlowIn,
      crossFadeState: item.isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: kThemeAnimationDuration,
    );
    subItems.add(subBody);
    return MaterialSlice(
        color: Colors.transparent,
        key: _SaltedKey<BuildContext, int>(context, index * 2),
        child: Column(children: subItems));
  }

  Widget createEmptyItem(MenuListItem item, int index) {
    return DragTarget(
      onMove: (e) {
        _dragEnterItem = item;
      },
      builder: (context, c, d) {
        return GNButton(
          Row(
            children: [GNText("")],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          backgroundColor:
              GNTheme().bGColorType(BGColorType.highlight).withAlpha(100),
          onPressed: () {},
        );
      },
    );
  }

  removeEmptyItem() {
    if (_emptyItem != null) {
      setState(() {
        if (_emptyItem.location.length <= 1) {
          _data.remove(_emptyItem);
        }
        if (_emptyItem.location.length > 1) {
          _data[_emptyItem.location[0]].subItems.remove(_emptyItem);
        }
        _emptyItem = null;
      });
    }
  }

  updateItemLocation() {
    _data.forEach((element) {
      int index1 = _data.indexOf(element);
      element.location = [index1];
      if (element.type == MenuListItemType.file &&
          element.subItems.length > 0) {
        element.subItems.forEach((element2) {
          int index2 = element.subItems.indexOf(element2);
          element2.location = [index1, index2];
        });
      }
    });
  }

  removeWillRemoveItem() {
    List<MenuListItem> data = [];
    _data.forEach((element) {
      if (!element.isWillRemove) {
        if (element.type == MenuListItemType.rss) {
          data.add(element);
        }
        if (element.type == MenuListItemType.file) {
          List<MenuListItem> sub = [];
          element.subItems.forEach((element2) {
            if (!element2.isWillRemove) {
              sub.add(element2);
            }
          });
          element.subItems = sub;
          data.add(element);
        }
      }
    });
    _data = data;
  }

  Draggable createDragItem(MenuListItem item, int index) {
    GNButtonIcon btn = GNButtonIcon(
      Row(
        children: [
          GNText(
            item.title,
            fontSize: GNTheme().fontSizeType(FontSizeType.md),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      ),
      [Icon(Icons.chevron_right, color: Colors.transparent)],
      backgroundColor: Colors.transparent,
      onPressed: () {},
    );
    if (item.type == MenuListItemType.file) {
      btn = GNButtonIcon(
        Row(
          children: [
            GNText(item.title,
                fontSize: GNTheme().fontSizeType(FontSizeType.md))
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        [
          Icon(item.isExpanded ? Icons.expand_more : Icons.chevron_right,
              color: GNTheme().fontColorType(FontColorType.bright))
        ],
        backgroundColor: Colors.transparent,
        onPressed: () {
          setState(() {
            item.isExpanded = !item.isExpanded;
          });
        },
      );
    }
    return LongPressDraggable(
        axis: Axis.vertical,
        onDragCompleted: () {
          if ((_nowDragItem.title != _dragEnterItem.title ||
                  _nowDragItem.type != _dragEnterItem.type) && (_nowDragItem.type != MenuListItemType.file || _dragEnterItem.type != MenuListItemType.file) ){
            if (_dragEnterItem.type == MenuListItemType.empty) {
              if (_dragEnterItem.location.length <= 1) {
                _data.insert(_dragEnterItem.location[0], _nowDragItem.copy());
              } else {
                _data[_dragEnterItem.location[0]]
                    .subItems
                    .insert(_dragEnterItem.location[1], _nowDragItem.copy());
              }
              _nowDragItem.isWillRemove = true;
            }
            if (_dragEnterItem.type == MenuListItemType.rss) {
              MenuListItem item = MenuListItem(
                  title: "new file",
                  type: MenuListItemType.file,
                  subItems: [_nowDragItem.copy(), _dragEnterItem.copy()]);
              _data.insert(_dragEnterItem.location[0], item);
              _nowDragItem.isWillRemove = true;
              _dragEnterItem.isWillRemove = true;
            }
            if (_dragEnterItem.type == MenuListItemType.file) {
              _dragEnterItem.subItems.insert(0, _nowDragItem.copy());
              _nowDragItem.isWillRemove = true;
            }
            setState(() {
              removeWillRemoveItem();
              updateItemLocation();
              _nowDragItem = null;
              _dragEnterItem = null;
            });
          }
          removeEmptyItem();
        },
        onDragEnd: (e) {
          removeEmptyItem();
          // _nowDragItem = null;
        },
        onDraggableCanceled: (v, o) {
          _nowDragItem = null;
          _dragEnterItem = null;
          removeEmptyItem();
        },
        onDragStarted: () {
          _nowDragItem = item;
        },
        child: DragTarget(
            onMove: (e) {
              _dragEnterItem = item;
              if (_nowDragItem != null && _nowDragItem.title != item.title) {
                if (_nowDragItem.type == MenuListItemType.file &&
                    _dragEnterItem.location.length > 1) {
                  return;
                }
                setState(() {
                  removeEmptyItem();
                  MenuListItem temp = MenuListItem(
                      title: _nowDragItem.title,
                      type: MenuListItemType.empty,
                      location: item.location);
                  if (temp.location.length <= 1) {
                    _data.insert(temp.location[0], temp);
                  }
                  if (temp.location.length > 1) {
                    _data[temp.location[0]]
                        .subItems
                        .insert(temp.location[1], temp);
                  }
                  _emptyItem = temp;
                });
              }
            },
            builder: (c, o, d) => btn),
        feedback: Container(
          height: 30,
          width: 100,
          child: GNButtonIcon(
            Row(
              children: [
                GNText(
                  item.title,
                  fontSize: GNTheme().fontSizeType(FontSizeType.md),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.start,
            ),
            [Icon(Icons.chevron_right, color: Colors.transparent)],
            backgroundColor: GNTheme().bGColorType(BGColorType.background),
            onPressed: () {},
          ),
        ));
  }

  List<MaterialSlice> getItem(List<MenuListItem> list) {
    List<MaterialSlice> items = [];
    list.forEach((item) {
      int index = list.indexOf(item);
      LocalKey key = _SaltedKey<BuildContext, int>(context, index * 2);
      if (item.type == MenuListItemType.rss) {
        items.add(MaterialSlice(
            color: Colors.transparent,
            key: key,
            child: createDragItem(item, index)));
      } else if (item.type == MenuListItemType.empty) {
        items.add(MaterialSlice(
            color: Colors.transparent,
            key: key,
            child: createEmptyItem(item, index)));
      } else {
        items.add(getSubContent(item, index));
      }
    });
    return items;
  }

  // final List<Item> _data = generateItems(8);
  @override
  Widget build(BuildContext context) {
    GNTheme theme = GNTheme(context);
    return Container(
        margin: EdgeInsets.only(top: 35, left: 8, right: 8),
        width: 200,
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  GNText(
                    "FRender",
                    color: theme.fontColorType(FontColorType.bright),
                    fontSize: theme.fontSizeType(FontSizeType.lg),
                    fontWeight: FontWeight.bold,
                  )
                ],
              ),
            ),
            Expanded(
                child: Column(
              children: [
                MergeableMaterial(
                  elevation: 0,
                  children: getItem(_data),
                )
              ],
            ))
          ],
        ));
  }
}

class _SaltedKey<S, V> extends LocalKey {
  const _SaltedKey(this.salt, this.value);

  final S salt;
  final V value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _SaltedKey<S, V> &&
        other.salt == salt &&
        other.value == value;
  }

  @override
  int get hashCode => hashValues(runtimeType, salt, value);

  @override
  String toString() {
    final String saltString = S == String ? "<'$salt'>" : '<$salt>';
    final String valueString = V == String ? "<'$value'>" : '<$value>';
    return '[$saltString $valueString]';
  }
}
