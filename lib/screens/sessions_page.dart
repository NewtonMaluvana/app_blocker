import 'package:app_blocker/components/anti_scroll_card.dart';
import 'package:app_blocker/components/lock_session_card.dart';
import 'package:app_blocker/constants/colors.dart';
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
                      child: Container(
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
                      child: Container(
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
              AntiScrollCard(
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
              AntiScrollCard(
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
