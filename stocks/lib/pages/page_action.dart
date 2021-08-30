import 'package:flutter/material.dart';
import '../tools/GNLog.dart';
enum PageName { main, menu, list, edit }
enum FuncName { clickMenu, clickTags, clickNote }

typedef void PageAction(PageName name, FuncName funcName, {List? data});

/// 用以同级 widget 之间调取方法 ，包含注册方法，调取方法，销毁方法
class GNPagesAction {
  static GNPagesAction? _m;
  final Map<PageName, Map<FuncName, Map<String, PageAction?>>> actionMap = {};

  factory GNPagesAction() {
    if (_m == null) {
      _m = GNPagesAction._internal();
    }
    return _m!;
  }

  // call func
  callAction(PageName pageName, FuncName funcName, {List? data}) {
    if (actionMap[pageName] == null) {
      actionMap[pageName] = {};
    }
    Map<String, PageAction?>? funcMap = actionMap[pageName]![funcName];
    if (funcMap != null) {
      funcMap.forEach((key, value) {
        if (value != null) {
          value(pageName, funcName, data: data);
          GNLog.log('$pageName=>$funcName:${data.toString()}');
        } else {
          GNLog.w('no func $pageName=>$funcName:${data.toString()}');
        }
      });
    }
  }

  // register func
  registerAction(
      PageName pageName, FuncName funcName, Widget widget, PageAction action) {
    if (actionMap[pageName] == null) {
      actionMap[pageName] = {};
    }
    if (actionMap[pageName]![funcName] == null) {
      actionMap[pageName]![funcName] = {};
    }
    if (actionMap[pageName]![funcName]![widget.toString()] == null) {
      actionMap[pageName]![funcName]![widget.toString()] = action;
    }
  }

  // dispose func 销毁，注册和销毁应该成对出现，销毁应该在调用者被销毁时调用此方法
  disposeAction(Widget widget) {
    actionMap.forEach((pageName, value) {
      value.forEach((funcName, value2) {
        value2.forEach((widgetName, action) {
          if (widgetName == widget.toString() && action != null) {
            actionMap[pageName]![funcName]![widgetName] = null;
          }
        });
      });
    });
  }

  GNPagesAction._internal();
}
