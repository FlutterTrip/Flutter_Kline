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
      scrollControllerListener();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  scrollControllerListener() {
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
      int oneScreenNum = (width / elementW).round();
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
                _nowDisplayData, config, _lastHqData, _nowKlinePoint),
          );

        case ChartType.Vol:
          config as VolChartConfig;
          return CustomPaint(
            child: Container(
              color: Colors.transparent,
              height: config.height.toDouble(),
            ),
            painter: VolPainter(_nowDisplayData, config),
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
          onScaleUpdate: (event) {
            print(event);
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
