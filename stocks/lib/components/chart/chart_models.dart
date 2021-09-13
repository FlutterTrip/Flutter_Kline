import 'package:flutter/material.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/models/dataModel.dart';

enum ChartType { Kline, Vol, fs, Grid}
enum ChartIndexType { ma }

class HqChartData extends HQData {}

class ChartBaseConfig {
  int width = 500; // 宽度可以自适应
  int height = 300;
  double lineWidth = 1;
  ChartType type = ChartType.Kline;

  bool isAutoWidth = false;
  int paddingTop = 8;
  int paddingBottom = 8;
  Color buy = GNTheme().getZDColor(ZDColorType.up);
  Color sell = GNTheme().getZDColor(ZDColorType.down);
}

class GridChartConfig extends ChartBaseConfig {
  int row = 3;
  int column = 3;
  double lineWidth = 0.5;
  Color color = Colors.grey.withAlpha(100);
  ChartType type = ChartType.Grid;
}


class KlineChartConfig extends ChartBaseConfig {
  int candleMinWidth = 10;
  int candleMaxWidth = 20;
  int candleNowWidth = 10;
  ChartType type = ChartType.Kline;
}

class VolChartConfig extends ChartBaseConfig {
  int elementMinWidth = 10;
  int elementMaxWidth = 20;
  int elementNowWidth = 10;
  int height = 100;
  ChartType type = ChartType.Vol;
}
