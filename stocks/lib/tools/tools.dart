import 'dart:async';

class GNTools {
  /// 函数防抖
  ///
  /// [func]: 要执行的方法
  /// [delay]: 要迟延的时长
  static Function debounce(Function func, [int milliseconds = 2000]) {
    Timer? timer;
    Duration delay = Duration(milliseconds: milliseconds);
    Function target = () {
      if (timer!.isActive ?? false) {
        timer!.cancel();
      }
      timer = Timer(delay, () {
        func!.call();
      });
    };
    return target;
  }

  /// 函数节流
  ///
  /// [func]: 要执行的方法
  static Function throttle(Future Function() func, [int milliseconds = 0]) {
    if (func == null) {
      return func;
    }
    bool enable = true;
    Function target = () {
      if (enable == true) {
        enable = false;
        func().then((_) {
          if (milliseconds == null || milliseconds <= 0) {
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
