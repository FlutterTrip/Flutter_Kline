import 'package:flutter/material.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/models/dataModel.dart';

enum ChartType {
  Kline,
  Vol,
  FS,
}
enum ChartIndexType { MA }

class HqChartData extends HQData {}

// 基础元素绘制属性
class ChartLineBaseConfig {
  double lineWidth = 0.5;
  Color lineColor = Colors.grey.withAlpha(100);
}

class ChartFontBaseConfig {
  double fontSize = GNTheme().fontSizeType(FontSizeType.s);
  Color fontColor = GNTheme().fontColorType(FontColorType.bright);
  Color fontBackground = Colors.transparent;
}

class ChartElementBaseConfig {
  int minWidth = 10;
  int maxWidth = 20;
  int nowWidth = 10;
}

// 背景网格
class GridConfig extends ChartLineBaseConfig with ChartFontBaseConfig {
  int row = 3;
  int column = 3;
}

// 指标图基础配置属性
class ChartIndexBaseConfig {
  ChartIndexType indexType = ChartIndexType.MA;
}

class ChartMAIndexConfig extends ChartIndexBaseConfig with ChartLineBaseConfig {
  Color lineColor = Colors.purple;
}

// 基础配置属性
class ChartBaseConfig {
  int width = 500; // 宽度可以自适应
  int height = 300;
  double lineWidth = 1;
  ChartType type = ChartType.Kline;
  List<ChartIndexBaseConfig> indexTypes = []; // 需要的指标配置，需要在图上绘制的

  bool isAutoWidth = false;
  int paddingTop = 8;
  int paddingBottom = 8;
  Color buy = GNTheme().getZDColor(ZDColorType.up);
  Color sell = GNTheme().getZDColor(ZDColorType.down);

  GridConfig gridConfig = GridConfig();


}

// class GridChartConfig extends ChartBaseConfig {
//   int row = 3;
//   int column = 3;
//   double lineWidth = 0.5;
//   Color color = Colors.grey.withAlpha(100);
//   ChartType type = ChartType.Grid;
// }

//  单独主图属性配置

// kline
class KlineChartConfig extends ChartBaseConfig with ChartElementBaseConfig {
  // int candleMinWidth = 10;
  // int candleMaxWidth = 20;
  // int candleNowWidth = 10;
  ChartType type = ChartType.Kline;
}

// vol
class VolChartConfig extends ChartBaseConfig with ChartElementBaseConfig {
  // int elementMinWidth = 10;
  // int elementMaxWidth = 20;
  // int elementNowWidth = 10;
  int height = 100;
  ChartType type = ChartType.Vol;
}
