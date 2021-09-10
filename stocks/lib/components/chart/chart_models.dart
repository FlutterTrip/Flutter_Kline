import 'package:flutter/material.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/models/dataModel.dart';

enum ChartType { Kline, line }
enum SubChartType { temp }

class HqChartData extends HQData {

}

class ChartConfig {
  int width = 500;
  int height = 300;
  int candleMinWidth = 10;
  int candleMaxWidth = 20;
  int paddingTop = 8;
  int paddingBottom = 8;
  Color buy = GNTheme().getZDColor(ZDColorType.up);
  Color sell = GNTheme().getZDColor(ZDColorType.down);
}
