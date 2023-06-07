import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner/qr_overlay.dart';
import 'package:qr_scanner/result_screen.dart';

const bgColor = Color(0xfffafafa);
MobileScannerController cameraController = MobileScannerController();



class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isScanCompleted = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  void closeScreen(){
    isScanCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            setState(() {
              isFlashOn = !isFlashOn;
            });
            cameraController.toggleTorch();
          }, icon: Icon(Icons.flash_on,color: isFlashOn ? Colors.blue : Colors.grey,)),
          IconButton(onPressed: (){
            setState(() {
              isFrontCamera = !isFrontCamera;
            });
            cameraController.switchCamera();
          }, icon: Icon(Icons.camera_front,color: isFrontCamera ? Colors.blue : Colors.grey,)),
        ],
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        title: const Text(
          "QR Scanner",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Place the QR code in the area",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

            ),
            Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: (capture) {
                        if(!isScanCompleted){
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            String code = barcode.rawValue ?? '---';
                            isScanCompleted = true;
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> ResultScreen(closeScreen: closeScreen,code: code,)));
                          }
                        }
                      },
                    ),
                    const QRScannerOverlay(overlayColour: bgColor,),
                  ],

                )
            ),
            Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Made by Bhanu Negi(bhanunegi420@gmail.com",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ]

                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
