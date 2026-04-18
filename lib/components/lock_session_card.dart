import 'package:block_apps/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

class LockSessionCard extends StatefulWidget {
  final String date;
  final String Time;
  final List<String> Apps;
  const LockSessionCard({
    super.key,
    required this.date,
    required this.Time,
    required this.Apps,
  });

  @override
  State<LockSessionCard> createState() => _LockSessionCardState();
}

class _LockSessionCardState extends State<LockSessionCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Color.fromARGB(255, 224, 195, 7), width: 4),
        ),
        color: color.bgColor2,
        borderRadius: BorderRadius.circular(20),
      ),
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
                        "Lock Session",
                        style: TextStyle(
                          fontSize: 15,
                          color: color.btnColor,
                          fontWeight: FontWeight.w500,
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
                              fontSize: 10,
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
                spacing: 2,
                children: [
                  Text(
                    "Time remaining",
                    style: TextStyle(fontSize: 12, color: color.colorText2),
                  ),
                  Text(widget.Time),
                ],
              ),
            ],
          ),
          Gap(20),
          LinearProgressBar(
            maxSteps: 100,
            minHeight: 4,
            currentStep: 70,
            progressColor: const Color.fromARGB(255, 224, 195, 7),
            backgroundColor: const Color.fromARGB(255, 231, 220, 238),
          ),
          Gap(10),
          Divider(color: color.colorText2, thickness: 1),

          //end of the card first row

          //start of the card second row
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("BlOCKED APPS", style: TextStyle(fontSize: 16)),
                  Gap(5),
                  // ListView.builder(
                  //   shrinkWrap: true,
                  //   itemCount: widget.Apps.length,
                  //   itemBuilder: (context, index) {
                  //     return Text(
                  //       widget.Apps[index],
                  //       style: TextStyle(color: color.colorText2),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ],
          ),
          Gap(10),
        ],
      ),
    );
  }
}
