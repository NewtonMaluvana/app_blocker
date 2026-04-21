import 'package:app_blocker/app_blocker.dart';
import 'package:block_apps/components/anti_scroll_card.dart';
import 'package:block_apps/components/lock_session_card.dart';
import 'package:block_apps/components/strict_mode_card.dart';
import 'package:block_apps/constants/colors.dart';
import 'package:block_apps/utils/blocker_service.dart';
import 'package:flutter/material.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  bool Strict = false;
  bool Anti = false;
  bool Session = false;
  int timeRemaining = 0;



  @override
  void initState() async {
    super.initState();
    //getShedule();
  }

  Future<void> getShedule() async {
    List<BlockSchedule> schedules = await BlockService.blocker.getSchedules();

    int hourtime = (schedules[0].endTime.hour * 60);
    int minutetime = (schedules[0].endTime.minute);

    int presentHour = TimeOfDay.now().hour;
    int presentMinute = TimeOfDay.now().hour;
    int totalTime = presentHour + presentMinute;

    int totalDuration = hourtime + minutetime;
    timeRemaining = totalDuration - totalTime;
  }

  List<Widget> get apps => [
    StrictModeCard(
      Apps: [
        "Facebook",
        "WhatsApp",
        "Twitter",
        "Instagram",
        "Snapchat",
        "WhatsApp",
        "Twitter",
        "Instagram",
        "Snapchat",
      ],
      date: "Start 2024-10-10",
      Time: timeRemaining.toString(),
    ),
   
    LockSessionCard(
      Apps: [
        "Facebook",
        "WhatsApp",
        "Twitter",
        "Instagram",
        "Snapchat",
        "WhatsApp",
        "Twitter",
        "Instagram",
        "Snapchat",
      ],
      date: "Start 2024-10-10",
      Time: "1 Day:2h:45 min",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          color: color.bgColor,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          Strict = true;
                          Session = false;
                          Anti = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: Strict
                                ? BorderSide(color: color.btnColor, width: 2)
                                : BorderSide(
                                    color: DefaultSelectionStyle.defaultColor,
                                    width: 1,
                                  ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.lock,
                              color: Strict
                                  ? color.btnColor
                                  : DefaultSelectionStyle.defaultColor,
                            ),
                            Text(
                              "Strict Mode",
                              style: TextStyle(
                                color: Strict
                                    ? color.btnColor
                                    : DefaultSelectionStyle.defaultColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          Anti = true;
                          Strict = false;
                          Session = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: Anti
                                ? BorderSide(color: color.btnColor, width: 2)
                                : BorderSide(
                                    color: DefaultSelectionStyle.defaultColor,
                                    width: 1,
                                  ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.phone_android,
                              color: Anti
                                  ? color.btnColor
                                  : DefaultSelectionStyle.defaultColor,
                            ),
                            Text(
                              "Ant-scroll",
                              style: TextStyle(
                                color: Anti
                                    ? color.btnColor
                                    : DefaultSelectionStyle.defaultColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          Session = true;
                          Strict = false;
                          Anti = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: Session
                                ? BorderSide(color: color.btnColor, width: 2)
                                : BorderSide(
                                    color: DefaultSelectionStyle.defaultColor,
                                    width: 1,
                                  ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.timer,
                              color: Session
                                  ? color.btnColor
                                  : DefaultSelectionStyle.defaultColor,
                            ),
                            Text(
                              "Session Lock",
                              style: TextStyle(
                                color: Session
                                    ? color.btnColor
                                    : DefaultSelectionStyle.defaultColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              //end of the navbar row
              
              StrictModeCard(
                Apps: [
                  "Facebook",
                  "WhatsApp",
                  "Twitter",
                  "Instagram",
                  "Snapchat",
                  "WhatsApp",
                  "Twitter",
                  "Instagram",
                  "Snapchat",
                ],
                date: "Start 2024-10-10",
                Time: "1 Day:2h:45 min",
              ),
              LockSessionCard(
                Apps: [
                  "Facebook",
                  "WhatsApp",
                  "Twitter",
                  "Instagram",
                  "Snapchat",
                  "WhatsApp",
                  "Twitter",
                  "Instagram",
                  "Snapchat",
                ],
                date: "Start 2024-10-10",
                Time: "1 Day:2h:45 min",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
