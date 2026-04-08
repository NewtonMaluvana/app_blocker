import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({super.key});

  State<WelcomePage> createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(decoration: BoxDecoration(color: Colors.blue)),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 131, 79, 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
