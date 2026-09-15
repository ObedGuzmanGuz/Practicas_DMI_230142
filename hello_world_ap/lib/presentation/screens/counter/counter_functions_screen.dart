import 'package:flutter/material.dart';

class CounterFunctionsScreen extends StatefulWidget {
  const CounterFunctionsScreen({super.key});

  @override
  State<CounterFunctionsScreen> createState() => _CounterFunctionsScreenState();
}




class _CounterFunctionsScreenState extends State<CounterFunctionsScreen> {
  int clickCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter functions'),
        actions: [
           IconButton(onPressed: () {

            setState(() {
              clickCounter = 0;
            }); 

         }, icon: const Icon(Icons.refresh_rounded,)),
        



        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$clickCounter',
              style: TextStyle(
                fontSize: 160,
                color: clickCounter > 0
                    ? Colors.green
                    : clickCounter < 0
                        ? Colors.red
                        : Colors.blue,
              ),
            ),
            Text(
              'Click${clickCounter == 1 ? '' : 's'}',
              style: const TextStyle(
                fontSize: 25,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
    //       children: [
    //          FloatingActionButton(
    //   shape: const StadiumBorder(),
    //   onPressed: () {
    //     clickCounter = 0;
    //     setState(() {
          
    //     });
    //   },
    //   child: const Icon(Icons.refresh_outlined), //boton de recargar
    // ),
    //         FloatingActionButton(
    //     onPressed: () {
    //       setState(() {
    //         clickCounter++;
    //       });
    //     },
    //     child: const Icon(Icons.plus_one),
    //   ),
   
      children:[
          CustomButton(icon: Icons.refresh_rounded,
          onPressed: () {
            clickCounter = 0;
            setState(() {
              
            });
          },
          ),
          const SizedBox(height: 10),
          CustomButton(icon: Icons.exposure_minus_1_outlined,
          onPressed: () {
            clickCounter--;
            setState(() {
            });
          },
          ),
          const SizedBox(height: 10),
          CustomButton(icon: Icons.plus_one,
          onPressed: () {
            clickCounter++;
            setState(() {});
          },),
          ],

      )
    );
  }
}

class CustomButton extends StatelessWidget {

final IconData icon;
final VoidCallback? onPressed;


  const CustomButton({
    super.key, required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      //shape: const StadiumBorder(),
      enableFeedback:true,
      elevation: 20,
      onPressed: onPressed,
      child:  Icon(icon),
    );
  }
}
