import 'package:app_blocker/app_blocker.dart';
import 'package:block_apps/constants/colors.dart';
import 'package:block_apps/utils/blocker_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

class StrictModeCard extends StatefulWidget {
  final String date;
  final String Time;
  final List<String> Apps;
  const StrictModeCard({
    super.key,
    required this.date,
    required this.Time,
    required this.Apps,
  });

  @override
  State<StrictModeCard> createState() => _StrictModeCardState();
}

class _StrictModeCardState extends State<StrictModeCard> {
  late Stream<int> _timerStream;
  TimeOfDay endTime = TimeOfDay(hour: 2, minute: 0);
  String timeDisplay = "00:00:00";

  String getTimeRemaining(TimeOfDay end) {
    final now = DateTime.now();

    DateTime targetDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      end.hour,
      end.minute,
    );

    if (targetDateTime.isBefore(now)) {
      targetDateTime = targetDateTime.add(Duration(days: 1));
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

    if (strict != null) {
      setState(() {
        endTime = strict.endTime; // ✅ directly assign endTime
      });
    }
  }

  @override
  void initState() {
    super.initState();
    timeDisplay = widget.Time;
    getShedule();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _timerStream,
      builder: (context, snapshot) {
        timeDisplay = widget.Time; // ✅ recalculates every second
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: const Color.fromARGB(255, 46, 115, 200),
                width: 4,
              ),
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
                            "Strict mode",
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
                                  color: const Color.fromARGB(
                                    255,
                                    16,
                                    192,
                                    112,
                                  ),
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
                      Text(
                        timeDisplay,
                      ), // ✅ uses local state instead of widget.Time
                    ],
                  ),
                ],
              ),
              Gap(20),
              LinearProgressBar(
                maxSteps: 8,
                minHeight: 4,
                currentStep: 1,
                progressColor: const Color.fromARGB(255, 46, 115, 200),
                backgroundColor: const Color.fromARGB(255, 231, 220, 238),
              ),
              Gap(10),
              Divider(color: color.colorText2, thickness: 1),
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("PHONE STATUS", style: TextStyle(fontSize: 16)),
                      Gap(5),
                      Row(
                        children: [
                          Icon(Icons.not_accessible),
                          Text(
                            "Entire phone locked",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 103, 102, 102),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Gap(10),
            ],
          ),
        );
      },
    );
  }
}
