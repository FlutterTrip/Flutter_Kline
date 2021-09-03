

class SumbolsManager {
  static SumbolsManager? _instance;
  
  static Instance() {
    if (_instance == null) {
      _instance = SumbolsManager._();
    }
    return _instance;
  }
  
  SumbolsManager._();

  
}