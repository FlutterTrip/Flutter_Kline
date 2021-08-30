import 'package:flutter/material.dart';

class FListView extends StatefulWidget {
  @override
  _FListViewState createState() => _FListViewState();
}

class _FListViewState extends State<FListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      constraints: BoxConstraints(maxWidth: 300),
    );
  }
}