// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Textboxes extends StatefulWidget {

  final int maxlength;

  //question mark allows it to be null
  final int? maxlines;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;

  const Textboxes({
    super.key, 
    required this.maxlength, 
    this.maxlines, 
    required this.hintText, 
    required this.controller,
    required this.focusNode});

  @override
  State<Textboxes> createState() => _TextboxesState();
}

class _TextboxesState extends State<Textboxes> {

// this allows you to go to the next input when you hit tab
final _focusnode1 = FocusNode();
final _focusnode2 = FocusNode();

@override
  void dispose() {
    _focusnode1.dispose();
    _focusnode2.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      controller: widget.controller,
      maxLength: widget.maxlength,
      maxLines: widget.maxlines,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: widget.hintText,

        //controls the color of the border when it is not selected
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 255, 255, 255),
          )
        ),

        //this controls the color of the border when it is selected
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blue
          )
        ),
        hintStyle: TextStyle(
          fontStyle: FontStyle.italic,
          color: const Color.fromARGB(255, 156, 156, 156),

        )
      ),
      style: TextStyle(
        color: Colors.white
      )

    );
  }
}