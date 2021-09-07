import 'package:flutter/material.dart';
import 'package:stocks/components/text/text.dart';
import 'package:stocks/models/tokenModel.dart';
import 'package:stocks/pages/page_action.dart';


class DetailView extends StatefulWidget {
  const DetailView({ Key? key }) : super(key: key);

  @override
  _DetailViewState createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  Pair? _pair;
  @override
  void initState() {
    GNPagesAction().registerAction(PageName.detail, FuncName.clickStock, widget, (name, funcName, {data}) { 
      if (data != null && data.length > 0) {
        Pair p = data[0];
        setState(() {
          _pair = p;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        GNText(_pair?.symbol ?? "--"),

      ],),
    );
  }
}