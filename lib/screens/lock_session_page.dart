import 'package:app_blocker/app_blocker.dart' hide AppInfo;
import 'package:block_apps/constants/colors.dart';
import 'package:block_apps/utils/blocker_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_input_box/auto_input_box.dart';
import 'package:installed_apps/app_info.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockSessionPage extends StatefulWidget {
  const LockSessionPage({super.key});

  @override
  State<LockSessionPage> createState() => _LockSessionPageState();
}

class _LockSessionPageState extends State<LockSessionPage> {
  TextEditingController sessionHoursController = TextEditingController();
  TextEditingController sessionNameController = TextEditingController();
  TextEditingController sessionMinutesController = TextEditingController();
  
 
  final int _Hours = 20;
  final int _Minutes = 20;
  String sessionName = "";
  int sessionHour = 0;
  int sessionMinute = 0;
  bool isHours = false;
  List<AppInfo> AppsList = [];
  Set<String> AppsListSelected = {};
  @override
  void initState() {
    super.initState();
  
  }
  //get the modal screen to add screens
  //getting the selcted apps from the phone storage
 

  //saving the blocked apps list to the phone storage
  //add schedule
  Future<void> getApps() async {
    try {
      List<AppInfo> appsList = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: true,
      );
      setState(() {     
        AppsList = appsList.where((i) => i.name != "Block Apps").toList();
        // (appsList.removeWhere((i) => {i.name == ""}));
      });
    } on PlatformException {
      print("Failed to get installed apps.");
    }
  }

  Future<void> BlockApps() async {
    try {
      await getApps();

      sessionName = sessionNameController.text;
      sessionHour = int.parse(sessionHoursController.text);
      sessionMinute = int.parse(sessionMinutesController.text);
     

      addSchedule(
        sessionName,
        AppsListSelected.toList(),
        sessionMinute,
        sessionHour,
      );
    } catch (e) {}
  }

  Future<void> addSchedule(
    String name,
    List<String> Apps,
    int minDuration,
    int hourDuration,
  ) async {
    await BlockService.blocker2.addSchedule(
      BlockSchedule(
        enabled: true,
        weekdays: [],
        id: "strict",
        name: name,
        scheduleDate: DateTime.now(),
        appIdentifiers: Apps.toList(),
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay(
          hour: TimeOfDay.now().hour + hourDuration,
          minute: TimeOfDay.now().minute + minDuration,
        ),
      ),
    );
    sessionHoursController.clear();
    sessionMinutesController.clear();
    sessionNameController.clear();
    AppsListSelected = {}; 
    
  }


 
  Future<void> _showAddAppsModal(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: color.bgColor,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "SELECT APPS TO BLOCK",
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.all(10),

                  child: SingleChildScrollView(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5, // 4 apps per row
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            // height relative to width
                          ),
                      itemBuilder: AppsList.isNotEmpty
                          ? (context, index) {
                              final app = AppsList[index];
                              return GestureDetector(
                                onTap: () {
                                  // Handleapp selection
                                  setModalState(() {
                                    if (AppsListSelected.contains(
                                      app.packageName,
                                    )) {
                                      AppsListSelected.remove(app.packageName);
                                    } else {
                                      AppsListSelected.add(app.packageName);
                                    }
                                  });

                                  
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),

                                  decoration: BoxDecoration(
                                    color:
                                        AppsListSelected.contains(
                                          app.packageName,
                                        )
                                        ? const Color.fromARGB(
                                            255,
                                            45,
                                            201,
                                            152,
                                          )
                                        : const Color.fromARGB(
                                            255,
                                            212,
                                            212,
                                            212,
                                          ),
                                    borderRadius: BorderRadius.circular(25),
                                  ),

                                  child: app.icon != null
                                      
                                      ? Image.memory(
                                          app.icon!,
                                          width: 4,
                                          height: 4,
                                        )
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
                ),

              ],
            );
          },
        );
      },
    );
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
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "SESSION NAME",

                            style: GoogleFonts.roboto(fontSize: 16),
                          ),
                        ],
                      ),
                      AutoInputBox(
                        textStyle: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 18,
                        ),
                        inputDecoration: InputDecoration(
                          hintText: "Name this session",
                          hintStyle: TextStyle(color: color.colorText2),
                          fillColor: color.btnColor,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textEditingController: sessionNameController,
                        suggestions: [""],
                        toDisplayString: (item) => item,
                      ),
                    ],
                  ),
                ),

                //end of the session name inputbox

                //start of the session duration inputbox
                

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
                        });
                        _showAddAppsModal(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.btnColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.all(15),
                        child: Text(
                          AppsListSelected.isNotEmpty ? "EDIT" : "ADD",

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
                  child: AppsListSelected.isNotEmpty
                      ? Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
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
                              children:
                                  AppsList.where(
                                    (app) =>
                                        AppsListSelected.contains(
                                      app.packageName,
                                    ),
                                  ).map((app) {
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
                                              : const Icon(
                                                  Icons.android,
                                                  size: 44,
                                                ),
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
                  onTap: () async {
                    BlockApps();
                  },
                  child: Container(child: (Text("block apps"))),
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color.btnColor,
                        ),
                      
                        onPressed: () {
                          if (AppsListSelected.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(bottom: 100),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: color.bgColor,
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      222,
                                      23,
                                      23,
                                    ),
                                    fontSize: 16,
                                  ),
                                  "Please add apps to block",
                                ),
                              ),
                            );
                            return;
                          }
                        },
                        child: Text(
                          "Add Session",
                          style: TextStyle(color: color.colorText),
                        ),
                      );
                    }
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                   
                  },
                  child: Container(child: (Text("Stopp apps"))),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
