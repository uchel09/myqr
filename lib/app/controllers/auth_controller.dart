import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  String? uid; // untuk cek kondisi, apakah user telah  login atau belum

  late FirebaseAuth auth;
  Future<Map<String, dynamic>> login(String email, String pass) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: pass);
      return {"error": false, "message": "Logout Berhasil"};
    } on FirebaseAuthException catch (e) {
      return {"error": true, "message": e.message};
    } catch (e) {
      return {"error": true, "message": "Tidak dapat Logout"};
    }
  }

  Future<Map<String, dynamic>> logoout() async {
    try {
      await auth.signOut();
      return {"error": false, "message": "Login Berhasil"};
    } on FirebaseAuthException catch (e) {
      return {"error": true, "message": e.message};
    } catch (e) {
      return {"error": true, "message": "Tidak dapat Login"};
    }
  }

  @override
  void onInit() {
    auth = FirebaseAuth.instance;

    auth.authStateChanges().listen((event) {
      uid = event?.uid;
    });
    super.onInit();
  }
}
