import 'dart:async';

import 'package:app_blocker/app_blocker.dart';
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
  String timeRemaining = "00:00:00";
  TimeOfDay endTime = TimeOfDay(hour: 2, minute: 0);
  late Timer _timer; // ✅ add timer




  @override
  void initState() {
    super.initState();
    _loadSchedule();
    // ✅ Call a void wrapper
  }

  // ✅ New void method that updates state
  Future<void> _loadSchedule() async {
    await getShedule();
  }

  String getTimeRemaining(TimeOfDay end) {
    final now = DateTime.now();

    DateTime targetDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      end.hour,
      end.minute,
    );

    // ✅ If end time has passed, show 00:00:00 instead of adding a day
    if (targetDateTime.isBefore(now)) {
      return "00:00:00";
    }

    final difference = targetDateTime.difference(now);

    String hours = difference.inHours.toString().padLeft(2, '0');
    String minutes = difference.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String seconds = difference.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }

  Future<void> getShedule() async {
    List<BlockSchedule> schedules = await BlockService.blocker2.getSchedules();

    final strict = schedules.firstWhere(
      (i) => i.id == "strict",
      // handle if not found
    );

    setState(() {
      endTime = strict.endTime; // ✅ actually assign endTime
      timeRemaining = getTimeRemaining(strict.endTime);
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        setState(() {
          timeRemaining = getTimeRemaining(endTime);
        });
      });
    });
  
  }

  List<Widget> get apps => [
    StrictModeCard(
      apps: [
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
      time: "",
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
                apps: [
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
                time: timeRemaining,
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
