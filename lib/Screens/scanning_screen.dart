import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'stored_data_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  QRScannerScreenState createState() => QRScannerScreenState();
}

class QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              // App bar area with a custom design
              Container(
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                child: const Center(
                  child: Text(
                    'Scan QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: Colors.blueAccent,
                      borderRadius: 15,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 250,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Instruction text
              const Text(
                'Align the QR code within the frame to scan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController myController) {
    controller = myController;
    controller?.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      // Automatically pause the camera and navigate to the next screen when data is detected
      if (result != null && result!.code!.isNotEmpty) {
        _pauseAndNavigate(result!.code!);
      }
    });
  }

  // Pause the camera and navigate to data screen
  Future<void> _pauseAndNavigate(String scannedData) async {
    // Pause the QR scanner
    await controller?.pauseCamera();

    // Fetch and store the data
    await _fetchAndStoreData(scannedData);

    // Resume the QR scanner when returning to this screen
    await controller?.resumeCamera();
  }

  Future<void> _fetchAndStoreData(String scannedData) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult[0] == ConnectivityResult.none) {
        // Offline
        print('Offline');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DataScreen(keyValue: scannedData.hashCode)),
        );
      } else {
        // Online
        print('Online');

        // Store qr code data
        var box = Hive.box('data');
        await box.put(scannedData.hashCode, scannedData);

        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('Text scanned and saved successfully!'),
        // ));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DataScreen(keyValue: scannedData.hashCode),
          ),
        );
      }
    } catch (e) {
      print('Error $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }
}
