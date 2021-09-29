import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stocks/components/chart/chart_models.dart';
import 'package:stocks/components/chart/renders/chart_kline_render.dart';
import 'package:stocks/components/chart/renders/chart_vol_render.dart';

class ChartContainer extends StatefulWidget {
  final List<ChartBaseConfig> configs;
  final List<HqChartData> datas;
  const ChartContainer({Key? key, required this.configs, required this.datas})
      : super(key: key);

  @override
  _ChartContainerState createState() => _ChartContainerState();
}

class _ChartContainerState extends State<ChartContainer> {
  double _scrollContentWidth = 500;
  List<HqChartData> _nowDisplayData = [];
  List<HqChartData> _datas = [];
  HqChartData? _lastHqData;
  Offset? _nowKlinePoint;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  double _offsetStartX = 0.0;
  double _offsetStartY = 0.0;
  int _scale = 1;
  int _scaleStart = 1;
  int _renderOffset = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(scrollControllerListener);
    super.initState();
  }

  @override
  void didUpdateWidget(ChartContainer oldWidget) {
    if (widget.configs.length > 0 && widget.datas.length > 0) {
      _lastHqData = widget.datas[widget.datas.length - 1];
      Object config = widget.configs[0];
      if (config is KlineChartConfig || config is VolChartConfig) {
        config as KlineChartConfig;
        int elementW = config.nowWidth;
        int paddingNum = config.paddingRight ~/ elementW;
        if (paddingNum == 0) {
          paddingNum = 1;
        }
        List<HqChartData> paddingData = List.generate(paddingNum, (index) {
          HqChartData m = HqChartData();
          m.isEmpty = true;
          return m;
        });
        _datas = [...widget.datas, ...paddingData];
        setState(() {
          _scrollContentWidth = _datas.length * config.nowWidth * 1.0;
        });
      }
      scrollControllerListener(true);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  scrollControllerListener([bool isForceRender = false]) {
    int offset = _scrollController.offset.toInt();
    if (offset >= 0 && _datas.length > 0 && widget.configs.length > 0) {
      
      Object config = widget.configs[0];
      
      Size? size = context.findRenderObject()?.paintBounds.size;

      int elementW = 0;
      if (config is KlineChartConfig || config is VolChartConfig) {
        config as KlineChartConfig;
        elementW = config.nowWidth;
      }
      
      config as ChartBaseConfig;

      int width = size == null ? config.width : size.width.toInt();
      if (offset % elementW <= 2 && !isForceRender && offset <= _scrollContentWidth - width - elementW && offset > elementW) {
        // 剔除无效渲染
        return;
      }
      // int oneScreenNum = width ~/ elementW + 1;
      // 计算需要渲染的元素数据起始
      int oneScreenNum = (width / elementW).round();
      // int oneScreenNum = 30;
      // oneScreenNum = (width / elementW) > oneScreenNum ? oneScreenNum + 1 : width ~/ elementW;
      // int rightNum = offset ~/ elementW;
      int rightNum = (offset / elementW).round();
      int fromNum = rightNum + oneScreenNum;
      if (fromNum > _datas.length) {
        // 一个屏幕显示的数量超出总共的数量
        fromNum = _datas.length;
      }
      int to = _datas.length - rightNum;
      if (to < 0) {
        _scrollController.jumpTo(_scrollContentWidth - width);
        return;
      }
      if (fromNum <= _datas.length) {
        List<HqChartData> nowDisplay = [];
        int from = _datas.length - fromNum;
        if (to == _datas.length - 1) {
          nowDisplay = [..._datas.sublist(from)];
        } else {
          nowDisplay = [..._datas.sublist(from, to)];
        }

        // 计算渲染的元素坐标偏移量
        int widthRight = (_scrollContentWidth - width - offset).toInt();
        int renderOffsetTemp = widthRight - nowDisplay[0].hqChartDataIndex * elementW;

        widget.configs.forEach((config) {
          if (config.maIndexTypes.length > 0) {
            int indexConfigIndex = 0;
            config.maIndexTypes.forEach((element) {
              int needLeftNum = element.ma;
              List<HqChartData> needLeftData = [];
              if (from >= needLeftNum) {
                needLeftData = _datas.sublist(from - needLeftNum, from + 1);
              }
              List<HqChartData> n = [...needLeftData, ...nowDisplay];
              List<HqChartData> t = [];
              n.forEach((element1) {
                if (!element1.isEmpty) {
                  t.add(element1);
                  if (t.length >= needLeftNum) {
                    double ma = 0;
                    t.forEach((element2) {
                      String typeNum =
                          element.maIndexType == ChartMAIndexType.CJL
                              ? element2.cjl
                              : element2.spj;
                      ma += double.parse(typeNum);
                    });
                    ma = ma / needLeftNum;
                    if (element.maIndexType == ChartMAIndexType.CJL) {
                      if (element1.cjlMa.length > indexConfigIndex) {
                        element1.cjlMa[indexConfigIndex] = ma;
                      } else {
                        element1.cjlMa.add(ma);
                      }
                    } else {
                      if (element1.ma.length > indexConfigIndex) {
                        element1.ma[indexConfigIndex] = ma;
                      } else {
                        element1.ma.add(ma);
                      }
                    }
                    t.removeAt(0);
                  }
                }
              });
              indexConfigIndex++;
            });
          }
        });

        setState(() {
          _nowDisplayData = nowDisplay;
          _renderOffset = renderOffsetTemp;
        });
      }
    }
  }

  Widget getReanderView(ChartBaseConfig config) {
    if (_datas.length > 0) {
      switch (config.type) {
        case ChartType.Kline:
          config as KlineChartConfig;
          return CustomPaint(
            child: Container(
              height: config.height.toDouble(),
            ),
            painter: CandlePainter(
                _nowDisplayData, config, _lastHqData, _nowKlinePoint, _renderOffset),
          );

        case ChartType.Vol:
          config as VolChartConfig;
          return CustomPaint(
            child: Container(
              color: Colors.transparent,
              height: config.height.toDouble(),
            ),
            painter: VolPainter(_nowDisplayData, config, _renderOffset),
          );

        default:
          return Container();
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> renderView = [];
    widget.configs.forEach((config) => renderView.add(getReanderView(config)));

    return MouseRegion(
        onExit: (event) {
          setState(() {
            _nowKlinePoint = null;
          });
        },
        onHover: (event) {
          if (event.localPosition >= Offset(0, 0)) {
            if (event.localPosition.dy <= 300) {
              setState(() {
                _nowKlinePoint = event.localPosition;
              });
            } else {
              setState(() {
                _nowKlinePoint = null;
              });
            }
          }
        },
        child: GestureDetector(
          onScaleStart: (details) {
            _scaleStart = _scale;
            _offsetStartX = _offsetX;
            _offsetStartY = _offsetY;
          },
          onScaleUpdate: (event) {
            bool isNeedUpdateChart = false;
            _updateNowWidth(config_) {
              int allLevel = config_.maxWidth - config_.minWidth;

              double scale =
                  min(max(_scaleStart * event.scale, 1), allLevel * 1.0 + 1);
              _scale = scale.toInt();
              _offsetX = _offsetStartX + event.localFocalPoint.dx;
              _offsetY = _offsetStartY + event.localFocalPoint.dy;
              int temp = config_.minWidth + _scale - 1;
              if (temp != config_.nowWidth) {
                config_.nowWidth = temp;
                isNeedUpdateChart = true;
              }
            }

            widget.configs.forEach((config) {
              if (config.type == ChartType.Kline ||
                  config.type == ChartType.Vol) {
                _updateNowWidth(config);
              }
            });
            if (isNeedUpdateChart) {
              scrollControllerListener();
            }

          },
          onLongPressDown: (event) {
            setState(() {
              _nowKlinePoint = null;
            });
          },
          onLongPress: () {
            setState(() {
              _nowKlinePoint = null;
            });
          },
          onLongPressCancel: () {
            setState(() {
              _nowKlinePoint = null;
            });
          },
          onLongPressEnd: (event) {
            setState(() {
              _nowKlinePoint = null;
            });
          },
          onLongPressMoveUpdate: (event) {
            if (event.localPosition >= Offset(0, 0)) {
              if (event.localPosition.dy <= 300) {
                setState(() {
                  _nowKlinePoint = event.localPosition;
                });
              } else {
                setState(() {
                  _nowKlinePoint = null;
                });
              }
            }
          },
          onLongPressUp: () {
            setState(() {
              _nowKlinePoint = null;
            });
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: renderView,
              ),
              Positioned.fill(
                  child: SingleChildScrollView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: Container(
                        width: _scrollContentWidth,
                      )))
            ],
          ),
        ));
  }
}
