import 'package:flutter/material.dart';
import 'package:hello_world_ap/presentation/screens/counter/counter_functions_screen.dart';
//import 'package:hello_world_ap/presentation/screens/counter/counter_screen.dart';
void main(){

runApp(MyApp());
 
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        fontFamily: 'Architext'
      ),
      home: const CounterFunctionsScreen()
    );
  }
  

}