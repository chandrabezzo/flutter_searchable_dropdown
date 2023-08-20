import 'package:flutter/widgets.dart';
import 'package:flutter_searchable_dropdown/src/not_given.dart';

class WidgetUtil {
  static Widget prepareWidget(
    dynamic object, {
    dynamic parameter = const NotGiven(),
    BuildContext? context,
    Function? stringToWidgetFunction,
  }) {
    if (object is Widget) {
      return object;
    }
    if (object is String) {
      if (stringToWidgetFunction == null) {
        return Text(object);
      } else {
        return stringToWidgetFunction(object);
      }
    }
    if (object is Function) {
      if (parameter is NotGiven) {
        if (context == null) {
          return prepareWidget(object(),
              stringToWidgetFunction: stringToWidgetFunction);
        } else {
          return prepareWidget(object(context),
              stringToWidgetFunction: stringToWidgetFunction);
        }
      }
      if (context == null) {
        return prepareWidget(object(parameter),
            stringToWidgetFunction: stringToWidgetFunction);
      }
      return prepareWidget(object(parameter, context),
          stringToWidgetFunction: stringToWidgetFunction);
    }
    return const SizedBox.shrink();
  }
}
