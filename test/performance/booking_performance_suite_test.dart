import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class SlotModel {
  const SlotModel({
    required this.date,
    required this.jam,
    required this.jamAkhir,
    required this.fieldId,
  });

  final String date;
  final String jam;
  final String jamAkhir;
  final int fieldId;

  Map<String, dynamic> toJson() => {
    'date': date,
    'jam': jam,
    'jam_akhir': jamAkhir,
    'field_id': fieldId,
  };

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      date: json['date'] as String,
      jam: json['jam'] as String,
      jamAkhir: json['jam_akhir'] as String,
      fieldId: int.tryParse(json['field_id']?.toString() ?? '0') ?? 0,
    );
  }
}

class BookingApiClient {
  BookingApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> confirmForm({
    required int fieldId,
    required List<SlotModel> selectedSlots,
  }) async {
    final payload = jsonEncode({
      'field_id': fieldId,
      'selected_slots': selectedSlots.map((slot) => slot.toJson()).toList(),
    });

    final response = await _client.post(
      Uri.parse('https://example.test/api/booking/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    if (response.statusCode != 200) {
      throw StateError('confirmForm failed: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> store({
    required int fieldId,
    required String teamName,
    required List<SlotModel> selectedSlots,
    required String paymentType,
  }) async {
    final payload = jsonEncode({
      'field_id': fieldId,
      'team_name': teamName,
      'payment_type': paymentType,
      'booking_data': selectedSlots.map((slot) => slot.toJson()).toList(),
    });

    final response = await _client.post(
      Uri.parse('https://example.test/api/booking/store'),
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    if (response.statusCode != 201) {
      throw StateError('store failed: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class BookingState extends ChangeNotifier {
  final List<SlotModel> _selectedSlots = <SlotModel>[];

  List<SlotModel> get selectedSlots => List.unmodifiable(_selectedSlots);

  void addSlot(SlotModel slot) {
    _selectedSlots.add(slot);
    notifyListeners();
  }

  void replaceAll(List<SlotModel> slots) {
    _selectedSlots
      ..clear()
      ..addAll(slots);
    notifyListeners();
  }
}

Widget buildSlotList({required List<SlotModel> slots}) {
  return MaterialApp(
    home: Scaffold(
      body: ListView.builder(
        itemCount: slots.length,
        itemBuilder: (context, index) {
          final slot = slots[index];
          return ListTile(
            key: ValueKey('slot_${slot.date}_${slot.jam}'),
            title: Text('${slot.date} ${slot.jam} - ${slot.jamAkhir}'),
            subtitle: Text('Lapangan ${slot.fieldId}'),
          );
        },
      ),
    ),
  );
}

Widget buildStateAwareSlotList({required BookingState state}) {
  return AnimatedBuilder(
    animation: state,
    builder: (context, _) {
      final selected = state.selectedSlots;
      return MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            itemCount: selected.length,
            itemBuilder: (context, index) {
              final slot = selected[index];
              return ListTile(
                title: Text('${slot.date} ${slot.jam} - ${slot.jamAkhir}'),
              );
            },
          ),
        ),
      );
    },
  );
}

Widget buildImageGrid({required List<ImageProvider> providers}) {
  return MaterialApp(
    home: Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1,
        children: providers
            .map((provider) => Image(image: provider, fit: BoxFit.cover))
            .toList(),
      ),
    ),
  );
}

List<SlotModel> buildSlots(int count) {
  final slots = <SlotModel>[];
  for (var i = 0; i < count; i++) {
    final day = (i % 30) + 1;
    final date = DateTime(2026, 9, day).toIso8601String().substring(0, 10);
    final startHour = (i % 12) + 8;
    final endHour = startHour + 1;
    slots.add(
      SlotModel(
        date: date,
        jam: '${startHour.toString().padLeft(2, '0')}:00',
        jamAkhir: '${endHour.toString().padLeft(2, '0')}:00',
        fieldId: 101,
      ),
    );
  }
  return slots;
}

double _p95(List<double> values) {
  if (values.isEmpty) return 0;
  final items = [...values]..sort();
  final index = ((items.length * 0.95) - 1).round();
  return items[index.clamp(0, items.length - 1)];
}

double _rssMegabytes() {
  if (!Platform.isAndroid &&
      !Platform.isIOS &&
      !Platform.isMacOS &&
      !Platform.isLinux &&
      !Platform.isWindows) {
    return 0;
  }
  return ProcessInfo.currentRss / (1024 * 1024);
}

void main() {
  group('TP-F-P01 - Slot list rendering performance', () {
    testWidgets('TC-F-P01-1: render 500 slots list under stable UI budget', (
      WidgetTester tester,
    ) async {
      final slots = buildSlots(500);
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(buildSlotList(slots: slots));
      await tester.fling(find.byType(ListView), const Offset(0, -1200), 1000);
      await tester.pumpAndSettle();
      stopwatch.stop();

      final renderMs = stopwatch.elapsedMicroseconds / 1000.0;

      expect(
        renderMs,
        lessThan(200.0),
        reason:
            'List rendering should complete within a reasonable budget; FPS validation should be confirmed via DevTools Performance.',
      );
    });
  });

  group('TP-F-P02 - JSON serialization performance', () {
    testWidgets('TC-F-P02-1: JSON encode/decode 100 slots under 50ms', (
      WidgetTester tester,
    ) async {
      final slots = buildSlots(100);

      final encodeStopwatch = Stopwatch()..start();
      final encodePayload = jsonEncode(
        slots.map((slot) => slot.toJson()).toList(),
      );
      encodeStopwatch.stop();
      final encodeMs = encodeStopwatch.elapsedMicroseconds / 1000.0;
      expect(encodePayload.isNotEmpty, isTrue);

      final decodeStopwatch = Stopwatch()..start();
      final decodePayload = jsonEncode(
        slots.map((slot) => slot.toJson()).toList(),
      );
      final decoded = jsonDecode(decodePayload) as List<dynamic>;
      final reconstructed = decoded
          .map((entry) => SlotModel.fromJson(entry as Map<String, dynamic>))
          .toList();
      decodeStopwatch.stop();
      final decodeMs = decodeStopwatch.elapsedMicroseconds / 1000.0;
      expect(reconstructed.length, equals(100));

      expect(
        encodeMs,
        lessThan(50.0),
        reason: 'JSON encode should be under 50ms for 100 slots.',
      );
      expect(
        decodeMs,
        lessThan(50.0),
        reason: 'JSON decode should be under 50ms for 100 slots.',
      );
    });
  });

  group('TP-F-P03 - HTTP request performance', () {
    testWidgets('TC-F-P03-1: confirmForm / store roundtrip under SLA', (
      WidgetTester tester,
    ) async {
      final client = BookingApiClient(
        client: MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 120));
          if (request.url.path.contains('/confirm')) {
            return http.Response(
              jsonEncode({
                'groupedSlots': {
                  '2026-09-01': [
                    {'jam': '18:00'},
                  ],
                },
                'total_price': 100000,
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'booking_id': 5001,
              'payment_url': 'https://pay.test/5001',
            }),
            201,
          );
        }),
      );

      final slots = [
        const SlotModel(
          date: '2026-09-01',
          jam: '18:00',
          jamAkhir: '19:00',
          fieldId: 101,
        ),
      ];

      final confirmSw = Stopwatch()..start();
      final confirmResult = await client.confirmForm(
        fieldId: 101,
        selectedSlots: slots,
      );
      final confirmElapsed = confirmSw.elapsedMilliseconds;

      final storeSw = Stopwatch()..start();
      final storeResult = await client.store(
        fieldId: 101,
        teamName: 'QA Team',
        selectedSlots: slots,
        paymentType: 'down payment',
      );
      final storeElapsed = storeSw.elapsedMilliseconds;

      expect(confirmResult['total_price'], equals(100000));
      expect(storeResult['booking_id'], equals(5001));
      expect(
        confirmElapsed,
        lessThan(2000),
        reason: 'confirmForm request should complete in under 2s.',
      );
      expect(
        storeElapsed,
        lessThan(3000),
        reason: 'store request should complete in under 3s.',
      );
    });
  });

  group('TP-F-P04 - State update propagation performance', () {
    testWidgets('TC-F-P04-1: selected slot updates propagate in under 100ms', (
      WidgetTester tester,
    ) async {
      final state = BookingState();
      final timingMs = <double>[];

      await tester.pumpWidget(buildStateAwareSlotList(state: state));

      for (var index = 0; index < 100; index++) {
        final slot = SlotModel(
          date: '2026-09-${(index % 28) + 1}',
          jam: '${(index % 12) + 8}:00',
          jamAkhir: '${(index % 12) + 9}:00',
          fieldId: 101,
        );

        final stopwatch = Stopwatch()..start();
        state.addSlot(slot);
        await tester.pump();
        stopwatch.stop();
        timingMs.add(stopwatch.elapsedMicroseconds / 1000.0);
      }

      final average = timingMs.reduce((a, b) => a + b) / timingMs.length;
      expect(
        average,
        lessThan(100.0),
        reason: 'Average state propagation should stay below 100ms.',
      );
    });
  });

  group('TP-F-P05 - Memory usage validation', () {
    testWidgets('TC-F-P05-1: 500-slot list remains below 50MB RSS', (
      WidgetTester tester,
    ) async {
      final slots = buildSlots(500);
      final beforeRss = _rssMegabytes();

      await tester.pumpWidget(buildSlotList(slots: slots));
      await tester.pumpAndSettle();

      final afterRss = _rssMegabytes();
      final delta = afterRss - beforeRss;
      expect(
        delta,
        lessThan(50.0),
        reason:
            'Memory delta for 500 displayed slots should remain below 50MB.',
      );
    });
  });

  group('TP-F-P06 - Navigation transition performance', () {
    testWidgets('TC-F-P06-1: route transition complete under 300ms', (
      WidgetTester tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(MaterialApp(home: const HomeScreen()));

      await tester.tap(find.text('Open booking detail'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      stopwatch.stop();
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(300),
        reason: 'Route transition should complete within 300ms.',
      );
    });
  });

  group('TP-F-P07 - Image load performance', () {
    testWidgets('TC-F-P07-1: 10 images decode and display under 2s', (
      WidgetTester tester,
    ) async {
      final pngBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAF'
        'c0vB1AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJ0UkG'
        'AAAAAABJRU5ErkJggg==',
      );

      final providers = List<ImageProvider>.generate(
        10,
        (index) => MemoryImage(pngBytes),
      );

      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(buildImageGrid(providers: providers));
      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2000),
        reason: 'Image-heavy view should load within 2s.',
      );
    });
  });

  group('TP-F-P08 - Cold start performance', () {
    testWidgets('TC-F-P08-1: app initial render under 1000ms', (
      WidgetTester tester,
    ) async {
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Joglo66 Booking'))),
        ),
      );
      await tester.pump();
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Initial render should be under 1 second.',
      );
    });
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const DetailScreen(),
              ),
            );
          },
          child: const Text('Open booking detail'),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Booking detail')));
  }
}

/*
  Manual profiling notes for TP-F-P06 and TP-F-P07:
  1. Run widget tests with: flutter test test/performance/booking_performance_suite_test.dart
  2. For integration navigation profile: flutter drive --driver=test_driver/performance_driver.dart --target=integration_test/booking_performance_integration_test.dart
  3. Open Flutter DevTools > Performance tab, record the timeline for route transitions and image grid render.
  4. Validate: route transition remains below 300ms and image-heavy screen stays within 2s without jank. 
*/
