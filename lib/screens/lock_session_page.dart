import 'package:flutter/material.dart';

class LockSessionPage extends StatefulWidget {
  const LockSessionPage({super.key});

  @override
  State<LockSessionPage> createState() => _LockSessionPageState();
}

class _LockSessionPageState extends State<LockSessionPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Lock Session')),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(flex: 1, child: Icon(Icons.lock)),
                Expanded(
                  flex: 3,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session Details'),
                      Text('Time Remaining: 30 mins'),
                      Text('Apps Locked: 5'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
