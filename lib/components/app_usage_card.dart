import 'dart:typed_data';

import 'package:block_apps/constants/colors.dart';
import 'package:flutter/material.dart';

class AppUsageCard extends StatefulWidget {
  final String AppName;
  final Uint8List icon;
  final String Time;
  final String Date;
  const AppUsageCard({
    super.key,
    required this.AppName,
    required this.Time,
    required this.icon,
    required this.Date,
  });

  @override
  State<AppUsageCard> createState() => _AppUsageCardState();
}

class _AppUsageCardState extends State<AppUsageCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: color.bgColor2,
        borderRadius: BorderRadius.circular(15),
        border: Border(
          top: BorderSide(
            color: const Color.fromARGB(255, 128, 0, 255),
            width: 4,
          ),
        )
        // border: Border.all(color: color.btnColor),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 5,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color.bgColor
                ),
                child: Image.memory(widget.icon, width: 15, height: 15),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flex(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.AppName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color.fromARGB(255, 52, 52, 52),
                        ),
                      ),
                    ],
                  ),
                  Flex(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Last opened 12 min ago",
                        style: TextStyle(fontSize: 12, color: color.colorText2),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Text(
                widget.Time.toString(),
                style: TextStyle(color: color.colorText2, fontSize: 14),
              ),
              Text(
                widget.Date,
                style: TextStyle(fontSize: 10, color: color.colorText3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
