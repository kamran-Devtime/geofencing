import 'package:flutter/material.dart';
import 'package:geofencing/home/home_view.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const HomeView()));
        }, child: const Text('Geofencing')),
      ),
    );
  }
}
