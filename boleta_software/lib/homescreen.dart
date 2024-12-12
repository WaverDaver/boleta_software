// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:typed_data';

import 'package:boleta_software/textboxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path_utils;


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


String person_selected = '';
bool entrar_pressed = false;
int entrar_pressed_count = 0;
Color blue = Colors.blue;
Color red = Colors.red;


//first row text variables (or else the table breaks because it can't have no rows at the start)
String row1_cantidad = '';
String producto_numero = '';
String row1_producto_nombre = '';
String row1_precio_unitario = '';
String row1_total = ''; 
bool row1_selected = false;
int row1count = 0;



//variables that are found after the database has been parsed and it found the names of
//the product that you are looking for and its price
String database_nombre = '';
String database_precio_unitario = '';
int database_precio_unitario_int = 0;
int total_for_row = 0;
String total_for_row_as_string = '';
int overall_price = 0;
String overall_price_as_string = '';


//this list will later be used to display all the products and prices on the printed receipt
List boleta_list = ["Producto          Cantidad          Precio Unitario          Total"];

//variable storing the file path of the database
String file_path_string = "";
List database = [];
bool databasejson_exists = false;


void person_selected_know(){
  print(person_selected);
  print(Directory.current);
}

//printing functionality
String receipt_as_string = '';
int receipt_amount = boleta_list.length;
int receipt_printing_count = 0;
var pdf = pw.Document();

Future<Uint8List> generatedPdf() async{

  for (var item in boleta_list){
    receipt_as_string += item + "\n";
  }
  var pdf = pw.Document();
  pdf.addPage(
    pw.Page(build: (context) => pw.Align(
      alignment: pw.Alignment.topLeft,
      child: pw.Text(
        receipt_as_string,
        style: pw.TextStyle(fontSize: 12),
      )
    ))
  );
  return pdf.save();
}

void pdf_print() async {
  final pdfbytes = await generatedPdf();

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfbytes);
}



class _HomeScreenState extends State<HomeScreen> {

//controllers are used to keep track of what the user is typing
final TextEditingController codigo_controller = TextEditingController();
final TextEditingController cantidad_controller = TextEditingController();
TextEditingController file_path_controller = TextEditingController();

final _focusnode1 = FocusNode();
final _focusnode2 = FocusNode();
final _focusnodeButton = FocusNode();
final _focusnodefilepath = FocusNode();

void dispose() {
    _focusnode1.dispose();
    _focusnode2.dispose();
    _focusnodeButton.dispose();
    _focusnodefilepath.dispose();
    // TODO: implement dispose
    super.dispose();
  }



void activating_database() async {
  //turns the directory file path into a string
  final straight_file_path = path_utils.join(Directory.current.path, 'database.json');

  final straight_file = File(straight_file_path);

  //checks if the file exists and displays it in the pop-up window
  if (await straight_file.exists()){
    setState(() {
        databasejson_exists = true;
    });
}

//decodes the json database as a string and then a list
  final string_json = await straight_file.readAsString();
  List straightjsondata = jsonDecode(string_json);

  //puts the json database into a list so its usable
  database = straightjsondata;

  //making the directory show in a textfield so the user can copy and paste it 
  //in the folders app to see if the database is really there
  file_path_controller.text = straight_file_path;

  setState(() {
    file_path_string = straight_file_path;
  });
  print("hola");
}

//after activating_database is run, this function can be used because the database
//is saved inside the variable, database

//this function searches inside of the database for the codigo that you are looking for
//that way through the database, you can find the name and precio of the product

int index_of_found_codigo = 0;

void database_search(String codigo){

  for (int i = 0; i < database.length; i++){

    //parses through the database to search for the right codigo
    Map <String, dynamic> maps_in_database = database[i];
    String codigos_in_database = maps_in_database.values.first;

    //once found, it will remember the index number of the location of that certain codigo
    if (codigos_in_database == codigo){
      index_of_found_codigo = i;
      print("NAME: " + database[i]['nombre']);
      database_nombre = database[i]['nombre'];
      database_precio_unitario = database[i]['precio_unitario'];
      database_precio_unitario_int = int.parse(database_precio_unitario);
    }
  }



}


 void handling_entrar(){
  if (entrar_pressed_count >= 1){
    setState(() {
        entrar_pressed_count = 0;
    });
    FocusScope.of(context).requestFocus(_focusnode1);
  }
 }

 void handling_borrar(){
  setState(() {
    row1_cantidad = '';
    row1_precio_unitario = '';
    row1_producto_nombre = '';
    row1_total = '';
    overall_price = 0;
    overall_price_as_string = '0';
    table_rows.clear();
  });

//removing everything in the printing list other than the titles
  boleta_list.removeRange(1, boleta_list.length);
  pdf = pw.Document();
  
 }

// "Producto   Cantidad   Precio Unitario   Total"
 void handling_total(){
  int cantidad_in_int = int.parse(cantidad_controller.text);
  int total_for_row = cantidad_in_int * database_precio_unitario_int;
  total_for_row_as_string = total_for_row.toString();

  boleta_list.add(database_nombre + "          " + cantidad_controller.text + "          " + database_precio_unitario + "          " + total_for_row_as_string);

  //adds this rows total to the TOTAL TOTAL 
  overall_price = overall_price + total_for_row;
  setState(() {
    overall_price_as_string = overall_price.toString();
  });

 }

 void adding_table(){
  setState(() {
    if (row1count == 1){
      row1_cantidad = cantidad_controller.text;
      row1_producto_nombre = database_nombre;
      row1_total = total_for_row_as_string;
      row1_precio_unitario = database_precio_unitario;
      table_rows[0] = DataRow(cells: [
        DataCell(Text(row1_cantidad, style: _table_text_style(),)),
        DataCell(Text(row1_producto_nombre, style: _table_text_style(),)),
        DataCell(Text(row1_precio_unitario, style: _table_text_style(),)),
        DataCell(Text(row1_total, style: _table_text_style(),)),
      ]);

    } else if (row1count >= 2){

      table_rows.add(DataRow(cells: [
      DataCell(Text(cantidad_controller.text, style: _table_text_style(),)),
      DataCell(Text(database_nombre, style: _table_text_style(),)),
      DataCell(Text(database_precio_unitario, style: _table_text_style(),)),
      DataCell(Text(total_for_row_as_string,style: _table_text_style(),)),

    ])
    );
    }

  });
 }

List <DataRow> table_rows = [DataRow(cells: [
  DataCell(Text(row1_cantidad)),
  DataCell(Text(row1_producto_nombre)),
  DataCell(Text(row1_precio_unitario)),
  DataCell(Text(row1_total)),
])];

int database_loading = 0;

  @override
  Widget build(BuildContext context) {

//loads the database once when the app is opened
    if (database_loading == 0){
      activating_database();
      database_loading = 1;
    }

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
                  //productos button

                  _mainbutton(person_selected_know, 'Productos'),

                  //file path button
                  OutlinedButton(onPressed: (){
                    showDialog(context: context, builder: (context){
                      return AlertDialog(
                        title: Text("File Path"),
                        actions: [
                          Textboxes(
                            maxlength: 100, 
                            hintText: "Presiona Load", 
                            controller: file_path_controller, 
                            focusNode: _focusnodefilepath,
                            textStyle: TextStyle(
                              color: Colors.black
                            ),),
                            Text("Database Found: " + databasejson_exists.toString()),
                            OutlinedButton(onPressed: 
                            activating_database, child: Text("Load", 
                             )),
                            OutlinedButton(onPressed: (){
                              //closes pop up window
                              Navigator.of(context).pop();
                               
                            }, 
                            child: Text("Cerrar"))
                        ],
                      );
                    });
                  }, 
                  style: OutlinedButton.styleFrom(
                    backgroundColor: blue,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero)
                  ),
                  child: Text("File Path", 
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.white
                  ),)),
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
                    focusNode: _focusnode1,
                    textStyle: TextStyle(
                      color: Colors.white
                    ),),
                
                
                     ),
                    SizedBox(width: 5,),
                  Expanded(
                    child: Textboxes(
                      maxlength: 5, 
                      maxlines: 1,
                      hintText: 'Cantidad', 
                      controller: cantidad_controller,
                      focusNode: _focusnode2,
                      textStyle: TextStyle(
                        color: Colors.white
                      ),),
                      
                  ),
                ],
              ),
            ),

            // ENTRAR BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: blue
                  ),
                  focusNode: _focusnodeButton,
                  onPressed: (){
                    database_search(codigo_controller.text);
                    producto_numero = codigo_controller.text;
                    handling_total();
                    setState(() {
                      entrar_pressed = true;
                      entrar_pressed_count = entrar_pressed_count + 1;
                      row1count = row1count + 1;
                      adding_table();
                      cantidad_controller.clear();
                      codigo_controller.clear();
                    });
                    handling_entrar();
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

                //TOTAL PRICE BELOW THE TABLE
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 300,
                  height: 75,
                  color: Colors.blueAccent,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Total: ",
                        style: TextStyle(fontSize: 35, fontStyle: FontStyle.italic),
                        children: <TextSpan>[
                          TextSpan(
                            text: overall_price_as_string,
                            style: TextStyle(fontSize: 35, fontStyle: FontStyle.normal)
                          )
                        ]
                      ),
          
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 10),

            //listo! and BORRAR button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: blue
                    ),
                    onPressed: pdf_print, 
                  child: Text("Listo!", style: TextStyle(
                    fontSize: 15,
          fontWeight: FontWeight.normal,
          color: Colors.white

                  ),)),

                  OutlinedButton(style: OutlinedButton.styleFrom(
                    backgroundColor: red
                  ), 
                  onPressed: handling_borrar, 
                  child: Text("Borrar",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Colors.white))),
                ],
              ),
            ),
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

  TextStyle _table_text_style(){
    return TextStyle(
      color: Colors.white,
      fontSize: 14,
    );
  }

  ButtonStyle _buttonstyle(){
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero
      )

    );
  }

}