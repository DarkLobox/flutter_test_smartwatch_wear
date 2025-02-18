import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:wear_plus/wear_plus.dart';

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
  final wearConnectivity = FlutterWearOsConnectivity();
  final random = Random();
  List<WearOsDevice> connectedDevices = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await wearConnectivity.configureWearableAPI();
    await dataChangeListener();
  }

  getSyncData() async {
    await getDevices();

    DataItem? dataItem = await wearConnectivity.findDataItemOnURIPath(
      pathURI: Uri(
          scheme: 'wear', host: connectedDevices.first.id, path: "/data-path"),
    );

    if (dataItem == null) return;
    showToast('--- sync data: ${dataItem.mapData}');
  }

  getDevices() async {
    connectedDevices = await wearConnectivity.getConnectedDevices();
    if (connectedDevices.isEmpty) showToast('Ningun dispisitivo conectado');
    setState(() {});
  }

  sendNumber() async {
    await getDevices();

    final number = random.nextInt(1000);
    final bytes = Uint8List.fromList(number.toString().codeUnits);

    await wearConnectivity.sendMessage(
      bytes,
      deviceId: connectedDevices.first.id,
      path: '/randomNumber',
      priority: MessagePriority.high,
    );
  }

  dataChangeListener() async {
    await getDevices();

    wearConnectivity
        .dataChanged(
      pathURI: Uri(
          scheme: "wear", host: connectedDevices.first.id, path: "/data-path"),
    )
        .listen(
      (dataEvents) {
        for (var event in dataEvents) {
          showToast(event.dataItem.mapData.toString());
        }
      },
    );
  }

  showToast(String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(label),
      duration: const Duration(milliseconds: 300),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WatchShape(
        builder: (BuildContext context, WearShape shape, Widget? child) {
          
          return AmbientMode(
            builder: (context, mode, child) {
              print('--- mode: $mode');
              print('--- shape: $shape');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: sendNumber,
                      child: const Text('Generar y Enviar'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        getSyncData();
                      },
                      child: const Text('Sincronizar'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
