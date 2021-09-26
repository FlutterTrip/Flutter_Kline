import 'package:flutter/material.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/pages/menu_view/menu_view.dart';
import 'package:stocks/pages/list_view/list_view.dart';
import 'package:stocks/manager/symbols_manager.dart';
import 'package:stocks/pages/detail_view/detail_view.dart';
import 'package:stocks/pages/page_action.dart';
import '../../manager/responsive.dart';
import '../../manager/method_channel_manger.dart';
import '../../nav/nav.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, GNResponsiveProtocol {
  late Widget _menu;
  late Widget _list;
  late Widget _detail;
  GNMainViewStatus _mainViewStatus = GNMainViewStatus.standard;
  GNMainViewSize? _nowSize;
  Pair? _detailPair;
  @override
  void initState() {
    GNResponsive.registerDelegate(this);
    _list = FListView();
    _menu = MenuView();
    loadData();
    SymbolsManager.instance();
    GNPagesAction()
        .registerAction(PageName.main, FuncName.clickStock, widget, clickStock);
    super.initState();
  }

  clickStock(PageName name, FuncName funcName, {List<dynamic>? data}) {
    if (data != null && data.length > 0) {
      Pair p = data[0];
      setState(() {
        _detailPair = p;
        // testData(p);
      });
      if (_nowSize != null && _nowSize == GNMainViewSize.small) {
         Nav().push(DetailView(pair: p));
      }
     
    }
  }

  loadData() async {
    // GNConfigManager manager = GNConfigManager();
    // await manager.loadConfig();
    // ConfigModel m = manager.model;
    // if (m.path.length > 0) {
    //   // TODO: There is no implementation failure time
    //   await GNFileManager().tryOpenLastPath();
    // } else {
    //   GNAlert(
    //       title: 'Tip',
    //       content: 'You need select folder',
    //       onPressedOK: (a) async {
    //         GNMethodChannelModel model = await GNFileManager().openFilePath();
    //         if (model.body['info'] == 'ok') {
    //           a.close();
    //         }
    //       }).show();
    //   // await _showMyDialog();
    // }
  }

  changeMainViewStatus(GNMainViewStatus status) {
    if (status != _mainViewStatus) {
      setState(() {
        _mainViewStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GNResponsive.getResponsive((GNMainViewSize s) {
      _nowSize = s;
      return Row(children: [
        Visibility(
          visible: GNMainViewSize.big == s,
          child: _menu,
        ),
        Expanded(
          child: _list,
          flex: GNMainViewSize.big == s ? 1 : 2,
        ),
        Visibility(
          visible: GNMainViewSize.big == s || GNMainViewSize.middle == s,
          child: Expanded(
            child: DetailView(pair: _detailPair),
            flex: 2,
          ),
        )
      ]);
    });
    // return Flex(
    //     direction: Axis.horizontal,
    //     children: [_menu, _list, Expanded(child: _detail)]);
    // return GNResponsive.getResponsive((GNMainViewSize s) {
    //   bool isShowMenu = true;
    //   bool isShowList = true;
    //   bool isShowDetail = true;
    //   switch (s) {
    //     case GNMainViewSize.middle:
    //     case GNMainViewSize.small:
    //       isShowMenu = true;
    //       isShowDetail = true;
    //       isShowList = true;
    //       break;
    //     case GNMainViewSize.big:
    //     default:
    //       isShowMenu = true;
    //       isShowList = true;
    //       isShowDetail = true;
    //       break;
    //   }
    //   if (_mainViewStatus == GNMainViewStatus.detail) {
    //     isShowMenu = false;
    //     isShowList = false;
    //   }
    //   return Flex(direction: Axis.horizontal, children: [
    //     Visibility(
    //       visible: isShowMenu,
    //       child: _menu,
    //     ),
    //     s == GNMainViewSize.small
    //         ? Expanded(
    //             child: Visibility(
    //             visible: isShowList,
    //             child: _list,
    //           ))
    //         : Visibility(
    //             visible: isShowList,
    //             child: _list,
    //           ),
    //     s == GNMainViewSize.small
    //         ? Visibility(
    //             visible: isShowDetail,
    //             child: _detail,
    //           )
    //         : Expanded(
    //             child: Visibility(
    //               visible: isShowDetail,
    //               child: _detail,
    //             ),
    //           )
    //   ]);
    // });
  }
}
