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


//all the colors
Color blue = Colors.blue;
Color red = Colors.red;
Color buttons_color = Color.fromRGBO(0, 123, 255, 1);
Color text_color = Color.fromRGBO(51, 51, 51, 1);
Color total_widget_color = Color.fromRGBO(100, 180, 100, 1);
Color all_background_color = Color.fromRGBO(240, 240, 240, 1);
Color table_header_text_color = Color.fromRGBO(255, 255, 255, 1);
Color table_background_color = Color.fromRGBO(40, 80, 160, 1);
Color table_text_color = Color.fromRGBO(30, 30, 30, 1);
Color table_rows_background_color = Color.fromRGBO(255, 255, 255, 1);
Color tab_background_color = Color.fromRGBO(50,100,200,1);
Color tab_text_color = Color.fromRGBO(255, 255, 255, 1);
Color entrar_button_color = Color.fromRGBO(40, 80, 160, 1);
Color listo_button_color = Color.fromRGBO(40, 80, 160, 1);



//first row text variables (or else the table breaks because it can't have no rows at the start)
String row1_cantidad = '';
String producto_numero = '';
String row1_producto_nombre = '';
String row1_precio_unitario = '';
String row1_por_mayor = "";
String row1_total = ''; 
bool row1_selected = false;
int row1count = 0;



//variables that are found after the database has been parsed and it found the names of
//the product that you are looking for and its price
String database_nombre = '';
String database_precio_unitario = '';
String database_por_mayor = '';
int database_precio_unitario_int = 0;
int database_por_mayor_int = 0;
int total_for_row = 0;
String total_for_row_as_string = '';
int overall_price = 0;
String overall_price_as_string = '';


//this list will later be used to display all the products and prices on the printed receipt
List<List<String>> boleta_list = [];

//variable storing the file path of the database
String file_path_string = "";
List database = [];
bool databasejson_exists = false;


void person_selected_know(){
  print(person_selected);
  print(Directory.current);
}

//printing functionality
int receipt_amount = boleta_list.length;
int receipt_printing_count = 0;
var pdf = pw.Document();

Future<Uint8List> generatedPdf() async{

// "Producto   Cantidad   Precio Unitario   Total"
  var pdf = pw.Document();
  pdf.addPage(
    pw.Page(build: (context) => pw.Align(
      alignment: pw.Alignment.topLeft,
      child: pw.Table(
        border: pw.TableBorder(
          horizontalInside: pw.BorderSide.none,
          verticalInside: pw.BorderSide.none),
        children: [
          pw.TableRow(children: [
            pw.Text('', textAlign: pw.TextAlign.left),
            pw.Text('', textAlign: pw.TextAlign.left),
            pw.Text('', textAlign: pw.TextAlign.left),
            pw.Text('Vendedor: ' + person_selected, textAlign: pw.TextAlign.left),
          ]),

          //making some space between the "Vendedor: " and the actual receipt table
          pw.TableRow(children: [
            pw.SizedBox(height:20),
          ]),


          //the head columns for the printed receipt table
          pw.TableRow(children: [
            pw.Text('Cantidad', textAlign: pw.TextAlign.left),
            pw.Text('Descripcion', textAlign: pw.TextAlign.left),
            pw.Text('Precio Unitario', textAlign: pw.TextAlign.left),
            pw.Text('Por Mayor',textAlign: pw.TextAlign.left),
            pw.Text('Valor', textAlign: pw.TextAlign.left),
          ]),

          //dividers
          pw.TableRow(children: [
            pw.Expanded(child: pw.Text("-----------------", textAlign: pw.TextAlign.left)),
            pw.Expanded(child: pw.Text("-----------------", textAlign: pw.TextAlign.left)),
            pw.Expanded(child: pw.Text("-----------------", textAlign: pw.TextAlign.left)),
            pw.Expanded(child: pw.Text("-----------------", textAlign: pw.TextAlign.left)),
            pw.Expanded(child: pw.Text("-----------------", textAlign: pw.TextAlign.left)),
          ]),

          //the three dots means spread, which allows dart to unpack each element
          //in the list of the list, so that it can add them individually
          ...boleta_list.map((item){
            return pw.TableRow(children: [
              pw.Text(item[1], textAlign: pw.TextAlign.left), //cantidad
              pw.Text(item[0], textAlign: pw.TextAlign.left), //descripcion
              pw.Text(item[2], textAlign: pw.TextAlign.left), //precio unitario
              pw.Text(item[3], textAlign: pw.TextAlign.left), // precio por mayor
              pw.Text(item[4], textAlign: pw.TextAlign.left), // total
            ],
            );
          
          }).toList(),

          //making some space between prices/products and the total
          pw.TableRow(children: [
            pw.SizedBox(height:20),
          ]),

          //final row displaying the total
          pw.TableRow(children: [
            pw.Text(''),
            pw.Text(''),
            pw.Text(''),
            pw.Text('TOTAL: '+ overall_price_as_string, textAlign: pw.TextAlign.left)
          ])
        ],
      ))
    ));
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


//makes sure the "attention", what the selected item is, is cleared after an action happens
void dispose() {
    _focusnode1.dispose();
    _focusnode2.dispose();
    _focusnodeButton.dispose();
    _focusnodefilepath.dispose();
    // TODO: implement dispose
    super.dispose();
  }


//runs the database and loads the data onto the straight_file variable
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
  print("database working");
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
      database_por_mayor = database[i]['por_mayor'];
      database_precio_unitario_int = int.parse(database_precio_unitario);
      database_por_mayor_int = int.parse(database_por_mayor);
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
    row1_por_mayor = "";
    row1_total = '';
    overall_price = 0;
    overall_price_as_string = '0';
    table_rows.clear();
  });

//removing everything in the printing list other than the titles
  boleta_list.removeRange(0, boleta_list.length);
  pdf = pw.Document();
  
 }

// "Producto   Cantidad   Precio Unitario   Total"
 void handling_total(){
  int cantidad_in_int = int.parse(cantidad_controller.text);
  if (cantidad_in_int >= 3){
     total_for_row = cantidad_in_int * database_por_mayor_int;
  } else{
     total_for_row = cantidad_in_int * database_precio_unitario_int;
  }
  total_for_row_as_string = total_for_row.toString();


//each row is saved to this boleta_list list, so that later they can be used to print out a receipt
  boleta_list.add([database_nombre, cantidad_controller.text,database_precio_unitario, database_por_mayor, total_for_row_as_string]);
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
      row1_por_mayor = database_por_mayor;
      row1_precio_unitario = database_precio_unitario;
      table_rows[0] = DataRow(
        color: WidgetStateProperty.all<Color>(table_rows_background_color),
        cells: [
        DataCell(Text(row1_cantidad, style: _table_text_style(),)),
        DataCell(Text(row1_producto_nombre, style: _table_text_style(),)),
        DataCell(Text(row1_precio_unitario, style: _table_text_style(),)),
        DataCell(Text(row1_por_mayor, style: _table_text_style(),)),
        DataCell(Text(row1_total, style: _table_text_style(),)),
      ]);

    } else if (row1count >= 2){

      table_rows.add(DataRow(
        color: WidgetStateProperty.all<Color>(table_rows_background_color),
        cells: [
      DataCell(Text(cantidad_controller.text, style: _table_text_style(),)),
      DataCell(Text(database_nombre, style: _table_text_style(),)),
      DataCell(Text(database_precio_unitario, style: _table_text_style(),)),
      DataCell(Text(database_por_mayor, style: _table_text_style(),)),
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
  DataCell(Text(row1_por_mayor)),
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
      backgroundColor: all_background_color,
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
                    backgroundColor: tab_background_color,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero)
                  ),
                  child: Text("File Path", 
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: tab_text_color
                  ),)),
                  Spacer(),

                  //menu to pick which worker
                      DropdownMenu(
                        textStyle: TextStyle(
                          color: Color.fromRGBO(240, 240, 240, 1),
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
                      color: Color.fromRGBO(30, 30, 30, 1),
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
                        color: Color.fromRGBO(30, 30, 30, 1)
                      ),),
                      
                  ),
                ],
              ),
            ),

            // ENTRAR BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)
                      ),
                      backgroundColor: entrar_button_color
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
                            color: Color.fromRGBO(255,255,255,1),
                          ),
                          ),),
                )
              ],
            ),

            SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: table_background_color,
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
                    color: Color.fromRGBO(200, 200, 200, 1)
                  ),
                  horizontalInside: BorderSide(
                    color: Color.fromRGBO(200, 200, 200, 1)
                  )
                ),


                columns: [
                  DataColumn(label: Text("Cantidad", 
                  style: TextStyle(
                    color: table_header_text_color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),)),
                  DataColumn(label: Text("Producto Nombre", style: TextStyle(
                    color: table_header_text_color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),)),
                  DataColumn(label: Text("Precio Unitario", style: TextStyle(
                    color: table_header_text_color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),)),
                  DataColumn(label: Text("Por Mayor", style: TextStyle(
                   color: table_header_text_color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),)),
                  DataColumn(label: Text("Total", style: TextStyle(
                    color: table_header_text_color,
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
                  //total widget color
                  color: total_widget_color,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Total: ",
                        style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
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
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      backgroundColor: listo_button_color,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)
                    ),
                    ),
                    onPressed: pdf_print, 
                  child: Text("Listo!", style: TextStyle(
                    fontSize: 15,
          fontWeight: FontWeight.normal,
          color: Colors.white

                  ),)),

                  ElevatedButton(style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)
                    ),
                    backgroundColor: Color.fromRGBO(220, 80, 80, 1)
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
          color: tab_text_color

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
      color: table_text_color,
      fontSize: 14,
      fontWeight: FontWeight.normal
    );
  }

  ButtonStyle _buttonstyle(){
    return OutlinedButton.styleFrom(
      backgroundColor: tab_background_color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero
      )

    );
  }

}