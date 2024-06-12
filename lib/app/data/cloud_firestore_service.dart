import 'dart:developer';

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

  Future<bool> updateUsers(String usersID, String name) async {
    try {
      await db.collection('users').doc(usersID).set({"name": name}, SetOptions(merge: true)); // Tunggu hingga proses selesai
      return true;
    } catch (error) {
      print("Failed to addPresence : $error");
      return false;
    }
  }

  // get specific doc in  `presence` collection's documents
  Future<List<Map<String, dynamic>>?> getSpesificPresence(String docID) async {
    try {
      DocumentSnapshot documentSnapshot = await db.collection('presence').doc(docID).get();
      List<Map<String, dynamic>> listPresence = [];

      if (documentSnapshot.exists) {
        // Menambahkan data dari documentSnapshot ke listPresence
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

        data.forEach((key, value) {
          if (key.startsWith('EMP-')) {
            listPresence.add(value as Map<String, dynamic>);
          }
        });

        return listPresence;
      } else {
        // Dokumen tidak ditemukan
        return null;
      }
    } catch (error) {
      print('Error getSpesificPresence: $error');
      return null;
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

      print("LIST PRESENCE : $listPresence");
    } catch (e) {
      print("Error fetching presence data: $e");
    }
    return listPresence;
  }

  // get all `presence` collection's documents by spesific month
  Future<List<Map<String, dynamic>>?> getDataForMonth(int year, int month) async {
    List<Map<String, dynamic>>? listPresence;

    try {
      // Membuat awalan nama dokumen untuk pencarian
      String searchPattern = '${month.toString().padLeft(2, '0')}-$year';

      // Membuat query untuk mencari dokumen dengan nama yang sesuai pola pencarian
      // QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('presence').where(FieldPath.documentId, isEqualTo: searchPattern).get();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('presence').get();
      listPresence = [];
      List<Map<String, dynamic>> filteredData = [];
      for (var doc in querySnapshot.docs) {
        String documentName = doc.id;
        if (documentName.contains(searchPattern)) {
          // Lakukan penyaringan data di sini
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          data.forEach((key, value) {
            if (key.startsWith('EMP')) {
              filteredData.add(value);
            }
          });
        }
      }
      listPresence.addAll(filteredData);
      // log("LIST PRESENCE ${listPresence.length} : $listPresence");
    } catch (e) {
      print("Error fetching data: $e");
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

  Future<void> deleteSelectedUser(String userID) async {
    try {
      // Membuat query untuk mendapatkan dokumen dengan userID yang sesuai
      QuerySnapshot querySnapshot = await db.collection('users').where('userID', isEqualTo: userID).get();

      // Jika ada dokumen yang sesuai dengan userID
      if (querySnapshot.docs.isNotEmpty) {
        // Hapus dokumen tersebut
        await querySnapshot.docs.first.reference.delete();
        print('User with userID $userID deleted successfully');
      } else {
        // Jika tidak ada dokumen yang sesuai dengan userID
        print('User with userID $userID not found');
      }
    } catch (error) {
      print("Failed to delete user: $error");
    }
  }

  Future<void> deleteUserDataFromAllDocuments(String userIDToRemove) async {
    try {
      // Query untuk mendapatkan semua dokumen presensi
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('presence').get();

      // Iterasi semua dokumen
      for (var doc in querySnapshot.docs) {
        // Ambil data dari dokumen
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        data.remove(userIDToRemove); // Menghapus langsung dengan key

        // Perbarui dokumen di Firestore
        await doc.reference.set(data); // Set data kembali ke dokumen
      }
    } catch (e) {
      print("Error deleting user data from all documents: $e");
    }
  }
}
