import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CloudFirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> addEmployee(Map<String, dynamic> data) async {
    // Tambahkan async
    // Add a new document with a generated ID
    var uuid = const Uuid().v4(); // Tidak perlu await di sini
    String shortId = "EMP-${uuid.substring(0, 5)}"; // Periksa jika uuid tidak null

    try {
      data.putIfAbsent("userID", () => shortId);
      await db.collection('users').doc(shortId).set(data); // Tunggu hingga proses selesai
      print('Added $data');
      return shortId;
    } catch (error) {
      print("Failed to addEmployee : $error");
      return "";
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

  // get specific doc in  `presence` collection's documents
  // Future<DocumentSnapshot>? getSpesificPresence(String docID) {
  //   db.collection('presence').doc(docID).get().then((DocumentSnapshot documentSnapshot) {
  //     if (documentSnapshot.exists) {
  //       // Dokumen ditemukan
  //       return documentSnapshot;
  //       // var fieldValue = documentSnapshot['nama_field'];
  //       // print('Nilai field: $fieldValue');
  //     } else {
  //       // print('Dokumen tidak ditemukan!');
  //       return null;
  //     }
  //   }).catchError((error) {
  //     print('Error getSpesificPresence: $error');
  //     return null;
  //   });
  //   return null;
  // }

  Future<bool> addPresence(String dateTimeNow, Map<String, dynamic> data, String userID) async {
    try {
      await db.collection('presence').doc(dateTimeNow).set({userID: data}, SetOptions(merge: true)); // Tunggu hingga proses selesai
      // print('Added Presence for $userID = $data');
      return true;
    } catch (error) {
      print("Failed to addPresence : $error");
      return false;
    }
  }

  // get selected `presence` collection's documents
  Future<DocumentSnapshot<Map<String, dynamic>>>? getPresence(String docID) {
    return db.collection('presence').doc(docID).get();
  }

  // get all `presence` collection's documents
  Future<List<Map<String, dynamic>>?> getAllPresence() async {
    List<Map<String, dynamic>>? listPresence;
    try {
      QuerySnapshot querySnapshot = await db.collection('presence').get();
      listPresence = [];

      for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
        listPresence.add(docSnapshot.data() as Map<String, dynamic>);
      }

      // print("LIST PRESENCE : $listPresence");
    } catch (e) {
      print("Error fetching presence data: $e");
    }
    return listPresence;
  }

  // delete all `users` collection's documents
  Future<void> deleteCollection(String collectionPath) async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection(collectionPath);

    // Get all documents in the collection
    QuerySnapshot querySnapshot = await collectionReference.get();

    // Delete each document in the collection
    for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.delete();
    }
  }
}
