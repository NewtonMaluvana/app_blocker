import 'package:flutter/material.dart';

  Future<void> showModal(BuildContext context)async{

           return showModalBottomSheet(context: context, builder:(BuildContext context){


       return Container(width: double.infinity,
                  height: 400,child: Text("This is a bottomsheet"),);
    });
  }
