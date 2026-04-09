import 'package:app_blocker/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

class SessionCard extends StatefulWidget {
  final String date;
  final String Time;
  final IconData incons;

  const SessionCard({
    super.key,
    required this.date,
    required this.Time,
    required this.incons,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.bgColor2,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(8),
      width: double.infinity,
      child: Column(
        children: [
          //first row of the card
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: color.btnColor),
                      color: const Color.fromARGB(255, 231, 220, 238),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: color.btnColor,
                    ),
                  ),
                  Gap(10),
                  Column(
                    children: [
                      Text("Focus session"),
                      Text(
                        widget.date,
                        style: TextStyle(
                          color: color.btnColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: color.btnColor),
                      color: const Color.fromARGB(255, 231, 220, 238),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(widget.Time),
                  ),
                  Gap(5),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: color.btnColor),

                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.settings, color: color.btnColor),
                  ),
                ],
              ),
            ],
          ),

          //end of first row of the card
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressBar(
              maxSteps: 10000,
              progressType: ProgressType.linear,
              currentStep: 1000,
              progressColor: color.btnColor,
              backgroundColor: Colors.grey,
              borderRadius: BorderRadius.circular(10),
              minHeight: 6,
            ),
          ),
          Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: [
              Flex(
                direction: Axis.horizontal,
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.btnColor),
                      color: const Color.fromARGB(255, 231, 220, 238),
                    ),
                    child: Icon(widget.incons, color: color.btnColor),
                  ),
                ],
              ),
              Gap(10),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: color.btnColor),
                  color: const Color.fromARGB(255, 231, 220, 238),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  direction: Axis.horizontal,
                  children: [
                    Icon(Icons.edit, color: color.btnColor, size: 20),
                    Gap(7),
                    Text("Edit"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
