import 'dart:async';
class GNTools {

  Timer? timer;
  /// 函数防抖
  ///
  /// [func]: 要执行的方法
  /// [delay]: 要迟延的时长
  Function debounce( Function func, [int milliseconds = 2000]) {
    
    Duration delay = Duration(milliseconds: milliseconds);
    Function target = (value) {
      if (timer != null && timer!.isActive) {
        timer!.cancel();
        timer = null;
      }
      timer = Timer(delay, () {
        Function.apply(func, value);
      });
    };
    return target;
  }

  /// 函数节流
  ///
  /// [func]: 要执行的方法
  Function throttle(Function func, [int milliseconds = 0]) {
    bool enable = true;
    Function target = (value) {
      if (enable == true) {
        enable = false;
         Function.apply(func, value).then((_) {
          if (milliseconds <= 0) {
            enable = true;
          } else {
            Duration delay = Duration(milliseconds: milliseconds);
            Timer(delay, () {
              enable = true;
            });
          }
        });
      }
    };
    return target;
  }
}
