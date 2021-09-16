
final double Precision = 0.5;

class ChartTools {
  static double convertY(double source, double height, double max, double min) {
    return height - ((source - min) / (max - min)) * height;
  }

  static double convertH(double source, double height, double max, double min) {
    double h = (source / (max - min)) * height;
    return h < Precision ? Precision : h;
  }
}
