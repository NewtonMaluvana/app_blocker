import 'package:block_apps/constants/colors.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
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
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: color.btnColor),
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("images/logo.png", width: 200),
                        Text(
                          " Stay focused by blocking distracting Apps that slows you down",
                          style: TextStyle(
                            fontSize: 30,
                            color: color.colorText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.bgColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                        topRight: Radius.zero,
                      ),
                    ),
                    width: double.infinity,

                    child: Flex(
                      verticalDirection: VerticalDirection.up,
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "One app . zero distractions",
                          style: TextStyle(color: Colors.black, fontSize: 25),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
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
                              Text(
                                "Get started",
                                style: TextStyle(fontSize: 20),
                              ),
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
