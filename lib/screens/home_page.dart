import 'package:block_apps/components/card.dart';
import 'package:block_apps/components/card2.dart';
import 'package:block_apps/components/session_card.dart';
import 'package:block_apps/constants/colors.dart';
import 'package:block_apps/screens/lock_session_page.dart';
import 'package:block_apps/screens/strict_mode.dart';
import 'package:block_apps/utils/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.btnColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          // ✅ CORRECT
                         
                          child: Container(
                            width: 150,
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
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome",
                          style: TextStyle(fontSize: 40, color: color.bgColor),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "You’re in control. Stay focused now!",
                            style: TextStyle(
                              fontSize: 25,
                              color: color.colorText2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(color: color.bgColor),

                width: double.infinity,
                child: Column(
                  children: [
                    ///start of the features card row
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 30),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Text(
                            "Features",
                            style: TextStyle(
                              color: color.colorText2,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 5,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const StrictModePage(),
                                    ),
                                  );
                                },
                                child: CardBox(
                                  Color: const Color.fromARGB(255, 204, 1, 1),
                                  title: "Strict Mode",
                                  icon: Icons.lock,
                                  subtitle: "lock the entire phone",
                                ),
                              ),

                              CardBox(
                                Color: color.btnColor,
                                title: "Anti-Scroll",
                                icon: Icons.phone_android,
                                subtitle: "block short videos only",
                              ),
                            ],
                          ),
                          Gap(10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LockSessionPage(),
                                ),
                              );
                            },
                            child: CardBox2(
                              Color: const Color.fromARGB(255, 224, 169, 5),
                              title: "Session Mode",
                              icon: Icons.timer,
                              subtitle:
                                  "Controll when and which apps are blocked",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //end of the features card row
              GestureDetector(
                onTap: () {
                  showModal(context);
                },
                child: Container(
                  
                  child: Text("Get permission")),
              ),
              //start of the session card row
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 30),
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Lock sessions",
                      style: TextStyle(
                        fontSize: 26,
                        color: color.colorText2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SessionCard(
                date: " ",
                time: "9:00 PM",
                icon: Icons.shopping_bag,
                onEdit: () {},
              ),
             
            ],
          ),
        ),
      ),
    );
  }
}
