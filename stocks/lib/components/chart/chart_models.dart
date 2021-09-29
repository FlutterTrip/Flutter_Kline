import 'package:flutter/material.dart';
import 'package:stocks/manager/theme_manager.dart';
import 'package:stocks/models/dataModel.dart';

enum ChartType {
  Kline,
  Vol,
  FS,
}
enum ChartIndexType { MA }

enum ChartMAIndexType { SPJ, CJL }

class HqChartData extends HQData {
  bool isEmpty = false; // 是否为空模型，为 true 时候，为填充作用
  List<double> ma = []; // 数据下标对应着，配置里指数配置的下标
  List<double> cjlMa = [];
  int hqChartDataIndex = 0; // 原始数据下标
}

// 基础元素绘制属性
class ChartLineBaseConfig {
  double lineWidth = 0.5;
  Color lineColor = Colors.grey.withAlpha(80);
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
  Color lineColor = Colors.yellowAccent;
  int ma = 5;
  ChartMAIndexType maIndexType = ChartMAIndexType.SPJ;
}

// 基础配置属性
class ChartBaseConfig {
  int width = 500; // 宽度可以自适应
  int height = 300;
  double lineWidth = 1;
  ChartType type = ChartType.Kline;
  List<ChartMAIndexConfig> maIndexTypes = []; // 需要的指标配置，需要在图上绘制的

  bool isAutoWidth = false;
  int paddingTop = 8;
  int paddingBottom = 8;
  int paddingRight = 100;
  Color buy = GNTheme().getZDColor(ZDColorType.up);
  Color sell = GNTheme().getZDColor(ZDColorType.down);

  GridConfig? gridConfig = GridConfig();


}

//  单独主图属性配置

// kline
class KlineChartConfig extends ChartBaseConfig with ChartElementBaseConfig {
  ChartType type = ChartType.Kline;
}

// vol
class VolChartConfig extends ChartBaseConfig with ChartElementBaseConfig {
  int height = 100;
  ChartType type = ChartType.Vol;
}
