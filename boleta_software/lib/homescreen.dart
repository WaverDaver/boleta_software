// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:boleta_software/textboxes.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


String person_selected = '';
bool entrar_pressed = false;
int entrar_pressed_count = 0;
Color blue = Colors.blue;

void person_selected_know(){
  print(person_selected);
}





class _HomeScreenState extends State<HomeScreen> {

//controllers are used to keep track of what the user is typing
final TextEditingController codigo_controller = TextEditingController();
final TextEditingController cantidad_controller = TextEditingController();

final _focusnode1 = FocusNode();
final _focusnode2 = FocusNode();
final _focusnodeButton = FocusNode();

void dispose() {
    _focusnode1.dispose();
    _focusnode2.dispose();
    _focusnodeButton.dispose();
    // TODO: implement dispose
    super.dispose();
  }

 void handling_entrar(){
  if (entrar_pressed_count >= 1){
    setState(() {
        entrar_pressed_count = 0;
    });
    FocusScope.of(context).requestFocus(_focusnode1);
  }
 }

List <DataRow> table_rows = [DataRow(cells: [
  DataCell(Text('')),
  DataCell(Text('')),
  DataCell(Text('')),
  DataCell(Text('')),
])];


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

                  //menu to pick which worker
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
            SizedBox(height: 10),

            //cantidad and codigo text fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(child: Textboxes(
                    maxlength: 5, 
                    maxlines: 1,
                    hintText: 'Codigo de Producto', 
                    controller: codigo_controller,
                    focusNode: _focusnode1,),
                
                
                     ),
                    SizedBox(width: 5,),
                  Expanded(
                    child: Textboxes(
                      maxlength: 5, 
                      maxlines: 1,
                      hintText: 'Cantidad', 
                      controller: cantidad_controller,
                      focusNode: _focusnode2,),
                      
                  ),
                ],
              ),
            ),

            //ENTRAR BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: blue
                  ),
                  focusNode: _focusnodeButton,
                  onPressed: (){
                    setState(() {
                      entrar_pressed = true;
                      entrar_pressed_count = entrar_pressed_count + 1;
                    });
                    handling_entrar();
                    print("Entrar pressed");
                    print(entrar_pressed_count);
                  }, 
                child: Text("Entrar",
                style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: Colors.white
        ),
        ),)
              ],
            ),

            SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 195, 192, 192),
                borderRadius: BorderRadius.circular(16.0)
              ),
              child: DataTable(

                //making the table lines only show on the inside
                border: TableBorder(
                  top: BorderSide.none,
                  bottom: BorderSide.none,
                  right: BorderSide.none,
                  left: BorderSide.none,
                  verticalInside: BorderSide(
                    color: Colors.white
                  ),
                  horizontalInside: BorderSide(
                    color: Colors.white
                  )
                ),


                columns: [
                  DataColumn(label: Text("Cantidad", 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),)),
                  DataColumn(label: Text("Producto Nombre", style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),)),
                  DataColumn(label: Text("Precio Unitario", style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),)),
                  DataColumn(label: Text("Total", style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),))
                  
                ], 
                rows: table_rows,
                  ),
            ),


                SizedBox(height: 10),

                
            //listo! button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: blue
                    ),
                    onPressed: null, 
                  child: Text("Listo!", style: TextStyle(
                    fontSize: 15,
          fontWeight: FontWeight.normal,
          color: Colors.white

                  ),)),
                ],
              ),
            )





          ],
        ),
      ),
    );
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