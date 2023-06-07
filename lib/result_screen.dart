import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner/qr_scanner.dart';

class ResultScreen extends StatefulWidget {
  final String code;
  final Function() closeScreen;
  const ResultScreen({super.key,required this.closeScreen,required this.code});


  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 2.0,
            leading: IconButton(
                onPressed: () {
                  widget.closeScreen();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)
            ),
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
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImageView(
                  data: widget.code,
                  size: 150,
                  version: QrVersions.auto,
                ),

                const Text(
                  "Scanned result",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  widget.code,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width - 100,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.code));
                      const snackBar = SnackBar(content: Center(child: Text(
                        "Copied to clipboard", style: TextStyle(
                          fontSize: 20, color: Colors.black54),)),
                        backgroundColor: Colors.white,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: const Text(
                      "COPY",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

  }
}
