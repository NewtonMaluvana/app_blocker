import 'package:app_blocker/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: color.bgColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 200,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Flex(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            direction: Axis.horizontal,
                            children: [
                              Icon(Icons.lock, color: Colors.amber),
                              Text(
                                "Premium",
                                style: TextStyle(color: color.colorText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.btnColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(color: color.bgColor),
                height: 200,
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Text(
                            "Features",
                            style: TextStyle(
                              color: color.colorText2,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
