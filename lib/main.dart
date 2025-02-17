import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';

void main() => runApp(const MyWearApp());

class MyWearApp extends StatelessWidget {
  const MyWearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WearScreen(),
    );
  }
}

class WearScreen extends StatefulWidget {
  const WearScreen({super.key});

  @override
  _WearScreenState createState() => _WearScreenState();
}

class _WearScreenState extends State<WearScreen> {
  final _wearConnectivity = FlutterWearOsConnectivity();
  final _random = Random();
  List<WearOsDevice> _connectedDevices = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _wearConnectivity.configureWearableAPI();
    _getDevices();
  }

  Future<void> _getDevices() async {
    _connectedDevices = await _wearConnectivity.getConnectedDevices();
  }

  Future<void> _sendNumber() async {
    await _getDevices();
    if (_connectedDevices.isEmpty) return;

    final number = _random.nextInt(1000);
    final bytes = Uint8List.fromList(number.toString().codeUnits);

    await _wearConnectivity.sendMessage(
      bytes,
      deviceId: _connectedDevices.first.id,
      path: '/randomNumber',
      priority: MessagePriority.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _sendNumber,
              child: const Text('Generar y Enviar'),
            ),
            const SizedBox(height: 10),
            Text('Dispositivos conectados: ${_connectedDevices.length}'),
          ],
        ),
      ),
    );
  }
}
