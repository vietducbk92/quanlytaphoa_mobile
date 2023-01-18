import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  bool isSuccess = false;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.black,
        previousPageTitle: "Hủy",
        middle: Text("Quét mã QR", style: TextStyle(color: Colors.white)),
      ),
      child: Column(
        children: <Widget>[
          Expanded(flex: 8, child: _buildQrView(context)),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              child: FutureBuilder(
                future: controller?.getFlashStatus(),
                builder: (context, snapshot) {
                  return snapshot.data == true
                      ? const Icon(Icons.flash_on,color: Colors.blueAccent,)
                      : const Icon(Icons.flash_off,color: Colors.blueAccent,);
                },
              ),
              onPressed: () async {
                await controller?.toggleFlash();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                fixedSize: const Size(70, 70),
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );

    // appBar: AppBar(title: const Text('Quét mã QR')),
    // body: Column(
    //   children: <Widget>[
    //     Expanded(flex: 4, child: _buildQrView(context)),
    //   ],
    // ),
    // floatingActionButton: FloatingActionButton(
    //   onPressed: () async {
    //     await controller?.toggleFlash();
    //     setState(() {});
    //   },
    //
    //   child: FutureBuilder(
    //     future: controller?.getFlashStatus(),
    //     builder: (context, snapshot) {
    //       return snapshot.data == true? Icon(Icons.flash_on):Icon(Icons.flash_off);
    //     },
    //   ),
    // ),
    //);
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      controller.resumeCamera();
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if (result != null && !isSuccess) {
        isSuccess = true;
        Navigator.pop(context, result?.code);
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    print("QRScanner dispose");
    controller?.dispose();
    super.dispose();
  }
}
