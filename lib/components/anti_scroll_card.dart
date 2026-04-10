import 'package:app_blocker/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

class AntiScrollCard extends StatefulWidget {
  final String date;
  final String Time;
  final List<String> Apps;
  AntiScrollCard({
    super.key,
    required this.date,
    required this.Time,
    required this.Apps,
  });

  @override
  State<AntiScrollCard> createState() => _AntiScrollCardState();
}

class _AntiScrollCardState extends State<AntiScrollCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: color.btnColor),
                      color: const Color.fromARGB(255, 231, 220, 238),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: color.btnColor,
                    ),
                  ),
                  Gap(10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Anti-scroll mode",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: const Color.fromARGB(255, 16, 192, 112),
                          ),
                          Text(
                            "Active now",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 16, 192, 112),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Text("Time remaining", style: TextStyle(fontSize: 20)),
                  Gap(5),
                  Text(widget.Time),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
