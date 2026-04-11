import 'package:app_blocker/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_input_box/auto_input_box.dart';
import 'package:flutter_time_duration_picker/flutter_time_duration_picker.dart';
import 'package:duration_picker_dialog_box/duration_picker_dialog_box.dart';

class LockSessionPage extends StatefulWidget {
  const LockSessionPage({super.key});

  @override
  State<LockSessionPage> createState() => _LockSessionPageState();
}

class _LockSessionPageState extends State<LockSessionPage> {
  TextEditingController sessionEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Lock Session')),
        body: Container(
          color: color.bgColor,
          child: Column(
            children: [
              // start of the fisrt row of the screen
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(15),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.btnColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.timer, color: color.bgColor2),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lock session',
                            style: GoogleFonts.roboto(
                              color: const Color.fromARGB(142, 13, 13, 13),
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'You choose exactly which apps to block and when.',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: color.colorText3,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: color.bgColor2,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'Custom block list',
                              style: GoogleFonts.roboto(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              //end of the fistrt row

              //start of the session name inputbox
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Flex(
                      children: [
                        Text(
                          "SESSION NAME",
                          style: GoogleFonts.roboto(fontSize: 16),
                        ),
                      ],
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                    AutoInputBox(
                      textStyle: TextStyle(
                        color: color.colorText,
                        fontSize: 18,
                      ),
                      inputDecoration: InputDecoration(
                        fillColor: const Color.fromARGB(255, 51, 49, 49),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      textEditingController: sessionEditingController,
                      suggestions: [""],
                      toDisplayString: (item) => item,
                    ),
                  ],
                ),
              ),

              //end of the session name inputbox

              //start of the session duration inputbox
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Flex(
                      children: [
                        Text(
                          "SESSION DURATION",
                          style: GoogleFonts.roboto(fontSize: 16),
                        ),
                      ],
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
