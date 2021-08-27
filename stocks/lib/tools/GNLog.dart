class GNLog {
  static void log(Object object) {
    DateTime time = DateTime.now();
    _log('GNLog: ${time.toString()} \n ${object} \n ======');
  }

  static void w(Object object) {
    DateTime time = DateTime.now();
    _log('**Warning! GNLog: ${time.toString()} \n ${object} \n ******');
  }

  static void e(Object object) {
    DateTime time = DateTime.now();
    _log('######ERROR! GNLog: ${time.toString()} \n ${object} \n ######');
  }

  static void _log(Object object) {
    print(object);
  }
}