import 'package:flutter/cupertino.dart';

PageRoute<T> appPageRoute<T>({required WidgetBuilder builder}) {
  return CupertinoPageRoute<T>(builder: builder);
}
