import 'package:app_blocker/constants/colors.dart';
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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(color: color.btnColor),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(color: color.btnColor),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.bgColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(45),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                        topRight: Radius.zero,
                      ),
                    ),
                    width: double.infinity,

                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hello There",
                          style: TextStyle(color: color.btnColor),
                        ),
                        Container(
                          height: 60,
                          width: 300,
                          padding: EdgeInsets.only(left: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: color.bgColor2,
                          ),
                          child: Flex(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            direction: Axis.horizontal,
                            children: [
                              Text("Get started"),
                              Container(
                                decoration: BoxDecoration(
                                  color: color.btnColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                width: 60,
                                height: 60,
                                child: Image.asset(
                                  color: color.bgColor2,
                                  scale: 0.5,
                                  width: 10,
                                  height: 10,
                                  "images/arrow-right.png",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
