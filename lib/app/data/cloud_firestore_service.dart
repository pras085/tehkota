import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CloudFirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<bool> addEmployee(Map<String, dynamic> data) async {
    // Tambahkan async
    // Add a new document with a generated ID
    var uuid = Uuid().v4(); // Tidak perlu await di sini
    String shortId = "EMP${uuid.substring(0, 5)}"; // Periksa jika uuid tidak null

    try {
      await db.collection('users').doc(shortId).set(data); // Tunggu hingga proses selesai
      print('Added $data');
      return true;
    } catch (error) {
      print("Failed to add : $error");
      return false;
    }
  }

  // get all `user` collection's documents
  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return db.collection('users').snapshots();
  }

  // get all `admin` collection's documents
  Future<DocumentSnapshot<Map<String, dynamic>>> getAdmin() {
    return db.collection('admin').doc('default').get();
  }
}
