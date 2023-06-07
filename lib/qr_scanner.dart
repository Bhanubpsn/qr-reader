import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner/main.dart';
import 'package:qr_scanner/qr_overlay.dart';
import 'package:qr_scanner/result_screen.dart';

const bgColor = Color(0xfffafafa);
MobileScannerController cameraController = MobileScannerController();





class QRScanner extends StatefulWidget {
  String id;
  String photoUrl;
  QRScanner(this.photoUrl,this.id, {super.key});

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
  void initState() {
    // TODO: implement initState
    super.initState();
    isScanCompleted = false;
    isFlashOn = false;
    isFrontCamera = false;
  }

  final db = FirebaseFirestore.instance;
  List datalist = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: db.collection('data').doc(widget.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text("");
          }
          var userDetails = snapshot.data;
          datalist = userDetails?['qrdata'];
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 2.0,
              actions: [
                IconButton(onPressed: () {
                  setState(() {
                    isFlashOn = !isFlashOn;
                  });
                  cameraController.toggleTorch();
                },
                    icon: Icon(Icons.flash_on,
                      color: isFlashOn ? Colors.blue : Colors.grey,)),
                IconButton(onPressed: () {
                  setState(() {
                    isFrontCamera = !isFrontCamera;
                  });
                  cameraController.switchCamera();
                },
                    icon: Icon(Icons.camera_front,
                      color: isFrontCamera ? Colors.blue : Colors.grey,)),
                IconButton(
                  onPressed: () {
                    print("Pressed");
                    logout();
                    Future.delayed(const Duration(seconds: 1), () {
                      googleLogin();
                    });
                  },
                  icon: const Icon(
                    Icons.lock_reset,
                  ),

                ),
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50.0)),
                                image: DecorationImage(
                                  image: NetworkImage(widget.photoUrl),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                            ),
                            const Text(
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
                              print("detected");
                              if (!isScanCompleted) {
                                final Barcode barcodes = capture.barcodes[0];

                                // for (final barcode in barcodes) {
                                  String code = barcodes.rawValue ?? '---';
                                  isScanCompleted = true;
                                  datalist.add(code);
                                  setState(() {
                                    db.collection('data').doc(widget.id).update({
                                      'qrdata' : datalist,
                                    });
                                  });
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) =>
                                          ResultScreen(closeScreen: closeScreen,code: code)));

                                // }
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
    );


  }

  late String photoUrl;
  late String id;
  late String name;

  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('data');
      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  googleLogin() async {
    print("googleLogin method Called");
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      var user = await _googleSignIn.signIn();
      if (user == null) {
        return;
      }

      final userData = await user.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: userData.accessToken, idToken: userData.idToken);
      var finalResult = await FirebaseAuth.instance.signInWithCredential(credential);
      print("Result $user");
      print(user.displayName);
      print(user.photoUrl);
      setState(() {
        photoUrl = user.photoUrl!;
        id = user.id!;
        List<String> fullname = user.displayName!.split(" ");
        name = fullname[0];
        if(name.length > 5){
          name = "${name.substring(0,5)}\n${name.substring(5,name.length)}";
        }
        print(name);
      });

      bool docExists = await checkIfDocExists(user.id);
      print("${docExists}user");
      if(!docExists)
      {
        await FirebaseFirestore.instance.collection('data').doc(user.id).set({
          "name" : user.displayName,
          "qrdata" : []
        });
        print("LogIn success");

        Get.offAll(() => QRScanner(photoUrl, id));
      }

      else
      {
      Get.offAll(() => QRScanner(photoUrl, id));
      }


    } catch (error) {
      print("errrooorrrr");
    }
  }

  Future<void> logout() async {
    await GoogleSignIn().disconnect();
    FirebaseAuth.instance.signOut();
  }
}
