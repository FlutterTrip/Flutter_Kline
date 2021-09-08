import 'package:flutter/material.dart';
import 'package:stocks/models/dataModel.dart';

enum ChartType { Kline, line }
enum SubChartType { temp }

class HqChartData extends HQData {

}

class ChartConfig {
  int width = 500;
  int heigh = 300;
  int candleMinWidth = 10;
  int candleMaxWidth = 20;
  int paddingTop = 8;
  int paddingBottom = 8;
  Color buy = Colors.green;
  Color sell = Colors.red;
}
