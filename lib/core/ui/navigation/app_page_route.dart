import 'package:flutter/cupertino.dart';

PageRoute<T> appPageRoute<T>({
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  return CupertinoPageRoute<T>(builder: builder, settings: settings);
}
