import 'package:flutter/widgets.dart';
import 'package:flutter_searchable_dropdown/src/not_given.dart';

class PrepareWidget extends StatelessWidget {
  const PrepareWidget({
    super.key,
    this.object,
    this.parameter = const NotGiven(),
    this.stringToWidgetFunction,
  });

  final dynamic object;
  final dynamic parameter;
  final Function? stringToWidgetFunction;

  @override
  Widget build(BuildContext context) {
    if (object is Widget) {
      return (object);
    }
    if (object is String) {
      if (stringToWidgetFunction == null) {
        return (Text(object));
      } else {
        return (stringToWidgetFunction?.call(object));
      }
    }
    if (object is Function) {
      if (parameter is NotGiven) {
        return PrepareWidget(
          object: object(context),
          stringToWidgetFunction: stringToWidgetFunction,
        );
      }
      return PrepareWidget(
        object: object(parameter, context),
        stringToWidgetFunction: stringToWidgetFunction,
      );
    }
    return (Text("Unknown type: ${object.runtimeType.toString()}"));
  }
}
