import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {

  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final Function(String) callback;

  const CustomDialogBox({
    Key? key,
    required this.textEditingController,
    required this.focusNode,
    required this.callback,
  }) : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return
      AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.white,
      title: Text('Custom Dialog Box'),
      content: TextField(
        controller: widget.textEditingController,
        focusNode: widget.focusNode,

      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Trigger callback function with entered text
            widget.callback(widget.textEditingController.text);
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}