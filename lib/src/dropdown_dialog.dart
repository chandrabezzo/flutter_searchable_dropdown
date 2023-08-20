import 'package:flutter/material.dart';
import 'pointer_this_please.dart';
import 'prepare_widget.dart';

class DropdownDialog<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final Widget? hint;
  final bool isCaseSensitiveSearch;
  final dynamic closeButton;
  final TextInputType? keyboardType;
  final Function? searchFn;
  final bool? multipleSelection;
  final List<int>? selectedItems;
  final Function? displayItem;
  final dynamic doneButton;
  final Function? validator;
  final bool? dialogBox;
  final PointerThisPlease<bool>? displayMenu;
  final BoxConstraints? menuConstraints;
  final Function? callOnPop;
  final Color? menuBackgroundColor;

  const DropdownDialog({
    Key? key,
    required this.items,
    this.hint,
    this.isCaseSensitiveSearch = false,
    this.closeButton,
    this.keyboardType,
    this.searchFn,
    this.multipleSelection,
    this.selectedItems,
    this.displayItem,
    this.doneButton,
    this.validator,
    this.dialogBox,
    this.displayMenu,
    this.menuConstraints,
    this.callOnPop,
    this.menuBackgroundColor,
  }) : super(key: key);

  @override
  DropdownDialogState<T> createState() => DropdownDialogState<T>();
}

class DropdownDialogState<T> extends State<DropdownDialog> {
  TextEditingController txtSearch = TextEditingController();
  TextStyle defaultButtonStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  List<int> shownIndexes = [];
  Function? searchFn;

  dynamic get selectedResult {
    return ((widget.multipleSelection ?? false)
        ? widget.selectedItems
        : widget.selectedItems?.isNotEmpty ?? false
            ? (widget.selectedItems == null)
                ? null
                : widget.items[widget.selectedItems!.first].value
            : null);
  }

  void _updateShownIndexes(String keyword) {
    if (searchFn != null) {
      shownIndexes = searchFn!(keyword, widget.items);
    }
  }

  @override
  void initState() {
    if (widget.searchFn != null) {
      searchFn = widget.searchFn;
    } else {
      Function matchFn;
      if (widget.isCaseSensitiveSearch) {
        matchFn = (item, keyword) {
          return (item.value.toString().contains(keyword));
        };
      } else {
        matchFn = (item, keyword) {
          return (item.value
              .toString()
              .toLowerCase()
              .contains(keyword.toLowerCase()));
        };
      }
      searchFn = (keyword, items) {
        List<int> shownIndexes = [];
        int i = 0;
        for (var item in widget.items) {
          if (matchFn(item, keyword) || (keyword?.isEmpty ?? true)) {
            shownIndexes.add(i);
          }
          i++;
        }
        return (shownIndexes);
      };
    }
    _updateShownIndexes('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 300),
      child: Card(
        color: widget.menuBackgroundColor,
        margin: EdgeInsets.symmetric(
            vertical: (widget.dialogBox == true) ? 10 : 5,
            horizontal: (widget.dialogBox == true) ? 10 : 4),
        child: Container(
          constraints: widget.menuConstraints,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              titleBar(),
              searchBar(),
              list(),
              closeButtonWrapper(),
            ],
          ),
        ),
      ),
    );
  }

  bool get valid {
    if (widget.validator == null) {
      return (true);
    }
    return (widget.validator?.call(selectedResult) == null);
  }

  Widget titleBar() {
    String validatorOutput;
    validatorOutput = widget.validator?.call(selectedResult);

    Widget validatorOutputWidget = valid
        ? const SizedBox.shrink()
        : Text(
            validatorOutput,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          );

    Widget doneButtonWidget =
        (widget.multipleSelection == true) || widget.doneButton != null
            ? PrepareWidget(
                object: widget.doneButton,
                parameter: selectedResult,
                stringToWidgetFunction: (string) {
                  return (TextButton.icon(
                      onPressed: !valid
                          ? null
                          : () {
                              pop();
                              setState(() {});
                            },
                      icon: const Icon(Icons.close),
                      label: Text(string)));
                })
            : const SizedBox.shrink();
    return widget.hint != null
        ? Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PrepareWidget(object: widget.hint),
                  Column(
                    children: <Widget>[doneButtonWidget, validatorOutputWidget],
                  ),
                ]),
          )
        : Column(
            children: <Widget>[doneButtonWidget, validatorOutputWidget],
          );
  }

  Widget searchBar() {
    return Stack(
      children: <Widget>[
        TextField(
          controller: txtSearch,
          decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
          autofocus: true,
          onChanged: (value) {
            _updateShownIndexes(value);
            setState(() {});
          },
          keyboardType: widget.keyboardType,
        ),
        const Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: Icon(
              Icons.search,
              size: 24,
            ),
          ),
        ),
        txtSearch.text.isNotEmpty
            ? Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: InkWell(
                    onTap: () {
                      _updateShownIndexes('');
                      setState(() {
                        txtSearch.text = '';
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  pop() {
    if (widget.dialogBox == true) {
      Navigator.pop(context);
    } else {
      widget.displayMenu?.value = false;
      widget.callOnPop?.call();
    }
  }

  Widget list() {
    return Expanded(
      child: Scrollbar(
        child: ListView.builder(
          itemBuilder: (context, index) {
            DropdownMenuItem item = widget.items[shownIndexes[index]];
            return InkWell(
              onTap: () {
                if (widget.multipleSelection == true) {
                  setState(() {
                    if (widget.selectedItems?.contains(shownIndexes[index]) ==
                        true) {
                      widget.selectedItems?.remove(shownIndexes[index]);
                    } else {
                      widget.selectedItems?.add(shownIndexes[index]);
                    }
                  });
                } else {
                  widget.selectedItems?.clear();
                  widget.selectedItems?.add(shownIndexes[index]);
                  if (widget.doneButton == null) {
                    pop();
                  } else {
                    setState(() {});
                  }
                }
              },
              child: (widget.multipleSelection == true)
                  ? widget.displayItem == null
                      ? (Row(children: [
                          Icon(
                            widget.selectedItems
                                        ?.contains(shownIndexes[index]) ==
                                    true
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Flexible(child: item),
                        ]))
                      : widget.displayItem?.call(item,
                          widget.selectedItems?.contains(shownIndexes[index]))
                  : widget.displayItem == null
                      ? item
                      : widget.displayItem
                          ?.call(item, item.value == selectedResult),
            );
          },
          itemCount: shownIndexes.length,
        ),
      ),
    );
  }

  Widget closeButtonWrapper() {
    return (PrepareWidget(
        object: widget.closeButton,
        parameter: selectedResult,
        stringToWidgetFunction: (string) {
          return (Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  pop();
                },
                child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 2),
                    child: Text(
                      string,
                      style: defaultButtonStyle,
                      overflow: TextOverflow.ellipsis,
                    )),
              )
            ],
          ));
        }));
  }
}
