@JS()
library my_lib; //Not avoid the library annotation

import "dart:js_util";

import "package:js/js.dart";

@JS()
external captureImageHtmlCanvas(num x, num y, num width, num height, num scale);
Future<String?> captureImageHtmlCanvasE(
    num x, num y, num width, num height, num scale) {
  final promise = captureImageHtmlCanvas(x, y, width, height, scale);
  return promiseToFuture(promise);
}
