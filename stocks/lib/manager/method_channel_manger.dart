import 'package:flutter/services.dart';
import '../tools/GNLog.dart';

const FilePlugin = MethodChannel('FilePlugin');
const Map<FilePluginFunc, String> FilePluginFuncMap = {
  FilePluginFunc.OpenNativePath: "OpenNativePath",
  FilePluginFunc.TryOpenLastPath: "TryOpenLastPath"
};
enum FilePluginFunc { TryOpenLastPath, OpenNativePath }

class GNMethodChannelModel {
  int? code;
  Map? body;
  GNMethodChannelModel({this.code, this.body});

  @override
  String toString() {
    // TODO: implement toString
    return "code:${code}, body:${body.toString()}";
  }
}

class GNMethodChannel {
  static callFilePlugin(FilePluginFunc funcName, [Map? data]) async {
    try {
      final Map result =
          await FilePlugin.invokeMethod("${FilePluginFuncMap[funcName]}");
      return GNMethodChannelModel(code: result["code"], body: result["body"]);
    } on PlatformException catch (e) {
      GNLog.w("${funcName}:${e.message}");
      return GNMethodChannelModel(code: -1, body: {"info": e.message});
    }
  }
}
