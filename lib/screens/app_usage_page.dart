import 'package:block_apps/components/app_usage_card.dart';
import 'package:block_apps/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:list_item_selector/list_item_selector.dart';

class AppUsagePage extends StatefulWidget {
  const AppUsagePage({super.key});

  @override
  State<AppUsagePage> createState() => _AppUsagePageState();
}

class _AppUsagePageState extends State<AppUsagePage> {
  String selectedValue = "Today";
  final List<String> items = ["Today", "This week", "This Month"];

  Widget getList() {
    return (Column(
      children: [
        ListItemSelector(
          focusedBorderColor: color.btnColor,
          borderRadius: 25,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          borderColor: color.btnColor,
          selectedValue: selectedValue,
          items: items,
          hintText: "Select time range",
          onChanged: (newValue) {
            setState(() {
              selectedValue = newValue!;
            });
          },
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: color.bgColor,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(10),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Apps Usage",
                    style: TextStyle(
                      color: color.colorText2,
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            Gap(10),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  width: 300,
                  child: getList(),
                ),
              ],
            ),
            Gap(3),

            AppUsageCard(
              AppName: "Facebook",
              icon: Icons.facebook,
              Time: " 2h:20min",
              Date: selectedValue,
            ),

            AppUsageCard(
              AppName: "Facebook",
              icon: Icons.facebook,
              Time: " 2h:20min",
              Date: selectedValue,
            ),

            AppUsageCard(
              AppName: "Instagram",
              icon: Icons.shopping_cart,
              Time: " 2h:20min",
              Date: selectedValue,
            ),
          ],
        ),
      ),
    );
  }
}
