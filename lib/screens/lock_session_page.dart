import 'package:app_blocker/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_input_box/auto_input_box.dart';
import 'package:installed_apps/app_info.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:installed_apps/installed_apps.dart';

class LockSessionPage extends StatefulWidget {
  const LockSessionPage({super.key});

  @override
  State<LockSessionPage> createState() => _LockSessionPageState();
}

class _LockSessionPageState extends State<LockSessionPage> {
  TextEditingController sessionEditingController = TextEditingController();
  int _Hours = 20;
  int _Minutes = 20;

  bool isHours = false;
  List<AppInfo> AppsList = [];
  List<AppInfo> AppsListSelected = [];

  //get the modal screen to add screens

  Future<void> _showAddAppsModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),

          child: SingleChildScrollView(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // 4 apps per row
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                // height relative to width
              ),
              itemBuilder: AppsList.length > 0
                  ? (context, index) {
                      final app = AppsList[index];
                      return GestureDetector(
                        onTap: () {
                          // Handleapp selection
                          setState(() {
                            if (AppsListSelected.contains(app.name)) {
                              AppsListSelected.remove(app);
                            } else {
                              AppsListSelected.add(app);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 1000),
                          decoration: BoxDecoration(
                            border: Border.all(color: color.btnColor),
                            color: color.bgColor2,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.all(5),
                          child: app.icon != null
                              ? Image.memory(app.icon!, width: 4, height: 4)
                              : const Icon(Icons.android, size: 4),
                        ),
                      );
                    }
                  : (context, index) {
                      return Container(child: Text("No apps found"));
                    },
              itemCount: AppsList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            ),
          ),
        );
      },
    );
  }

  Future<void> getApps() async {
    try {
      List<AppInfo> appsList = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: true,
      );
      setState(() {
        AppsList = (appsList);
      });
    } on PlatformException {
      print("Failed to get installed apps.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Lock Session')),
        body: Container(
          color: color.bgColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                // start of the fisrt row of the screen
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(15),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.btnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.timer, color: color.bgColor2),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lock session',
                              style: GoogleFonts.roboto(
                                color: const Color.fromARGB(142, 13, 13, 13),
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'You choose exactly which apps to block and when.',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: color.colorText3,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: color.bgColor2,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                'Custom block list',
                                style: GoogleFonts.roboto(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                //end of the fistrt row

                //start of the session name inputbox
                Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Flex(
                        children: [
                          Text(
                            "SESSION NAME",
                            style: GoogleFonts.roboto(fontSize: 16),
                          ),
                        ],
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.start,
                      ),
                      AutoInputBox(
                        textStyle: TextStyle(
                          color: color.colorText,
                          fontSize: 18,
                        ),
                        inputDecoration: InputDecoration(
                          hintText: "Name this session",
                          fillColor: const Color.fromARGB(255, 51, 49, 49),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textEditingController: sessionEditingController,
                        suggestions: [""],
                        toDisplayString: (item) => item,
                      ),
                    ],
                  ),
                ),

                //end of the session name inputbox

                //start of the session duration inputbox
                Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Flex(
                        children: [
                          Text(
                            "SESSION DURATION",
                            style: GoogleFonts.roboto(fontSize: 16),
                          ),
                        ],
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.start,
                      ),

                      NumberPicker(
                        value: isHours ? _Hours : _Minutes,
                        minValue: 0,
                        maxValue: 10000,
                        onChanged: (value) => setState(() {
                          if (isHours) {
                            _Hours = value;
                          } else {
                            _Minutes = value;
                          }
                        }),
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isHours = true;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Text("Hours"),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 51, 49, 49),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _Hours.toString(),
                                      style: GoogleFonts.roboto(
                                        color: color.colorText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(""),
                              Container(
                                child: Text(
                                  ":",
                                  style: TextStyle(
                                    color: color.colorText3,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isHours = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Text("Minutes"),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 51, 49, 49),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _Minutes.toString(),
                                      style: GoogleFonts.roboto(
                                        color: color.colorText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                //end of the session duration inputbox

                //start of the Apps to block section
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.all(15),
                      child: Text(
                        "APPS TO BLOCK",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: color.btnColor,
                        ),
                      ),
                    ),

                    //add/edit utton to add apps which are to be blocked
                    GestureDetector(
                      onTap: () {
                        //Handle edit/add functionality
                        setState(() {
                          getApps();
                          _showAddAppsModal(context);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.btnColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.all(15),
                        child: Text(
                          AppsListSelected.length > 0 ? "EDIT" : "ADD",

                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: color.colorText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Container(
                  child: AppsListSelected.length > 0
                      ? Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: color.btnColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 2,
                              runSpacing: 2,
                              children: AppsListSelected.map((app) {
                                return Container(
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: color.bgColor2,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      app.icon != null
                                          ? Image.memory(
                                              app.icon!,
                                              width: 44,
                                              height: 44,
                                            )
                                          : const Icon(Icons.android, size: 44),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : Container(
                          child: Text(
                            "No apps selected",
                            style: GoogleFonts.roboto(fontSize: 28),
                          ),
                        ),
                ),
                GestureDetector(
                  onTap: () {
                    getApps();
                  },
                  child: Container(child: Text("Get installed apps")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
