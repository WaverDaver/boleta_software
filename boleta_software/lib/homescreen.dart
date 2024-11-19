// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:boleta_software/textboxes.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


String person_selected = '';




class _HomeScreenState extends State<HomeScreen> {

final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color.fromARGB(255, 42, 44, 53),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _mainbutton(person_selected_know, 'Productos'),
                  Spacer(),
                      DropdownMenu(
                        textStyle: TextStyle(
                          color: Colors.white
                        ),
                        onSelected: (value){
                          setState(() {
                            person_selected = value.toString();
                          });
                        } ,
                        dropdownMenuEntries: <DropdownMenuEntry<String>>[
                          DropdownMenuEntry(value: 'Luisa', label: 'Luisa'),
                          DropdownMenuEntry(value: 'Jorge', label: 'Jorge'),
                          DropdownMenuEntry(value: 'Victor', label: 'Victor')
                        ],
                        leadingIcon: Icon(Icons.person),
                        ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(child: Textboxes(
                  maxlength: 5, 
                  hintText: 'Cantidad', 
                  controller: titleController)),
                  SizedBox(width: 5,),
                Expanded(
                  child: Textboxes(
                    maxlength: 5, 
                    hintText: 'Codigo de Producto', 
                    controller: titleController),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

void person_selected_know(){
  print(person_selected);
}

//main functions to create different buttons rapidly and declutter the space above
  //used for all top left buttons 
  OutlinedButton _mainbutton(onPressed, String text){
    return OutlinedButton(
      onPressed: onPressed, 
      style: _buttonstyle(),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: Colors.white

        ),
        ),
      );
  }

  IconButton _iconbutton(Function()? onPressed, IconData icon){
    return IconButton(
      onPressed: onPressed, 
      icon: Icon(
        icon,
        color: Colors.grey,));
  }


  ButtonStyle _buttonstyle(){
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero
      )

    );
  }

}