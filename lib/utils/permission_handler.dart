import 'package:app_blocker/app_blocker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

Future<void> checkPermission() async {
  final blocker = AppBlocker.instance;
  try {
    final s = await AppBlocker.instance.requestPermission();
  } catch (e) {}
}
  Future<void> showModal(BuildContext context)async{

           return showModalBottomSheet(context: context, builder:(BuildContext context){


      return Center(
        child: GestureDetector(
          onTap: () async {
            checkPermission();
          },
          child: SizedBox(
            width: double.infinity,
            height: 400,
            child: Text("Get permission"),
          ),
        ),
      );
    });
  }

