import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:qr_scanner/qr_scanner.dart';



class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome!",
                style: TextStyle(
                    color: Colors.yellow.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 25
                ),
              ),
              const SizedBox(height: 25,),
              InkWell(
                child: Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.7),
                    border: Border.all(color: Colors.black,),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue with Google",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  googleLogin();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = db.collection('data');
      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  late String photoUrl;
  late String id;
  late String name;

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
      print(user.email);
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
      if(!docExists)
      {
        await db.collection('data').doc(user.id).set({
          "name" : user.displayName,
          "qrdata" : []
        });
        print("LogIn success");

        Get.offAll(() => QRScanner(photoUrl,id));
      }

      else
      {
        Get.offAll(() => QRScanner(photoUrl,id));
      }


    } catch (error) {
      print("errrooorrrr");
    }
  }







}


