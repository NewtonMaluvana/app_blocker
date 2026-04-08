import 'package:app_blocker/constants/colors.dart';
import 'package:flutter/material.dart';

class CardBox extends StatefulWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  final Color;

  CardBox({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.Color,
  });

  @override
  State<CardBox> createState() => _CardBoxState();
}

class _CardBoxState extends State<CardBox> {
  double width = 0;
  double iconsize = 0;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width; //get the device width
    if (width > 400) {
      iconsize = 70;
    } else if (width < 400) {
      iconsize = 50;
    }
    return Container(
      padding: EdgeInsets.all(5),
      width: width * 0.49,
      height: width * 0.49,
      decoration: BoxDecoration(
        color: widget.Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Flex(
        spacing: 10,
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: color.colorText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Icon(widget.icon, size: iconsize, color: color.bgColor2),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: color.colorText2, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
