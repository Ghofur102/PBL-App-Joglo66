//import 'dart:developer';

//import 'package:flutter/material.dart';
//import 'package:flutter_test/flutter_test.dart';
//import 'package:integration_test/integration_test.dart';

//void main() {
  //IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  //testWidgets('TP-F-P06 integration: navigation under 300ms', (
    //WidgetTester tester,
 // ) async {
    //final stopwatch = Stopwatch()..start();

    //await tester.pumpWidget(MaterialApp(home: const _PerfHomeScreen()));

    //await tester.tap(find.text('Open booking detail'));
   // await tester.pump();
    //await tester.pump(const Duration(milliseconds: 250));
   // stopwatch.stop();

    //expect(stopwatch.elapsedMilliseconds, lessThan(300));
    //expect(find.text('Booking detail'), findsOneWidget);
  //});
//}

//class _PerfHomeScreen extends StatelessWidget {
  //const _PerfHomeScreen();

  //@override
 /// Widget build(BuildContext context) {
    //return Scaffold(
      //body: Center(
      ///  child: ElevatedButton(
          //onPressed: () {
         //Navigator.of(context).push(
              //MaterialPageRoute<void>(
                //builder: (_) => const _PerfDetailScreen(),
              //),
            //;
          //},
          //child: const Text('Open booking detail'),
        //),
      //),
    //);
  //}
//}

//class _PerfDetailScreen extends StatelessWidget {
  //const _PerfDetailScreen();

  //@override
  //Widget build(BuildContext context) {
    //return const Scaffold(body: Center(child: Text('Booking detail')));
  //}
//}
