import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/modules/home/home_controller.dart';
import 'package:uuid/uuid.dart';

import '../utils/utils.dart';

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

  // get `jam - admin` collection's documents
  Future<DocumentSnapshot<Map<String, dynamic>>> getOfficeHours() {
    return db.collection('admin').doc('jam').get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getOfficeHoursLembur() {
    return db.collection('admin').doc('jam-lembur').get();
  }

  Future<void> updateOfficeHours(Map<String, dynamic> newValue) async {
    try {
      // Ambil dokumen spesifik dari koleksi 'users'
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('admin').doc("jam").get();

      // Cek jika dokumen ditemukan
      if (snapshot.exists) {
        // Ambil data dari dokumen
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        if (data.containsKey("pagi")) {
          data["pagi"]["jamMasuk"] = newValue["pagi"]["jamMasuk"];
          data["pagi"]["jamKeluar"] = newValue["pagi"]["jamKeluar"];
        }
        if (data.containsKey("sore")) {
          data["sore"]["jamMasuk"] = newValue["sore"]["jamMasuk"];
          data["sore"]["jamKeluar"] = newValue["sore"]["jamKeluar"];
        }
        // Update dokumen di Firestore
        await snapshot.reference.update(data).whenComplete(() {
          return Utils.showToast(TypeToast.success, 'Update selesai.');
        }).onError((error, stackTrace) {
          throw "$error";
        });

        // print('User $userID updated in document with ID ${doc.id}');
      } else {
        Utils.showToast(TypeToast.error, 'Data does not exist.');
      }
    } catch (e) {
      Utils.showToast(TypeToast.error, '$e');
    }
  }

  Future<void> updateOfficeHoursLembur(Map<String, dynamic> newValue) async {
    await FirebaseFirestore.instance.collection('admin').doc("lembur").set(newValue).onError((error, stackTrace) {
      return Utils.showToast(TypeToast.error, '$error');
    }).whenComplete(() {
      return Utils.showToast(TypeToast.success, 'Update selesai.');
    });
  }

  Future<bool> addPresence(String dateTimeNow, Map<String, dynamic>? data, String userID) async {
    if (data == null) return false;
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

  Future<bool> updateAdmin(String email, String password) async {
    try {
      await db.collection('admin').doc("default").set({
        "email": email,
        "password": password,
      }, SetOptions(merge: true)); // Tunggu hingga proses selesai
      return true;
    } catch (error) {
      print("Failed to updateAdmin : $error");
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
    int split(String val, bool pickFirst) {
      if (val.contains(":")) {
        var parts = val.split(":");
        return int.parse(pickFirst ? parts.first : parts.last);
      }
      return int.parse(val); // return the original value if there is no colon
    }

    List<Map<String, dynamic>>? listPresence;
    Rxn<Map<String, dynamic>> officeHoursFromDb = Rxn<Map<String, dynamic>>();
    try {
      var res = await getOfficeHours();
      if (res.exists) {
        officeHoursFromDb.value = res.data();
        officeHoursFromDb.refresh();
        print(officeHoursFromDb.value);
      } else {
        throw "Error";
      }

      var shiftPagi = officeHoursFromDb.value?["pagi"];
      var shiftSore = officeHoursFromDb.value?["sore"];
      QuerySnapshot querySnapshot = await db.collection('presence').get();
      listPresence = [];
      // querySnapshot.docs.forEach((doc) {
      //   print('Document ID: ${doc.id}');
      //   print('Data: ${doc.data()}');
      //   print('-------------------');
      // });

      if (querySnapshot.docs.isNotEmpty) {
        // Iterasi melalui setiap dokumen
        for (var doc in querySnapshot.docs) {
          // Iterasi melalui setiap user di dalam dokumen
          Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;

          // log("LIST PRESENCE : $docData");
          // Iterasi melalui setiap user di dalam dokumen
          docData.forEach((userID, presenceData) async {
            // Cek jika tidak ada logout_presence, tambahkan atau perbarui dengan login_presence
            if (!presenceData.containsKey('logout_presence')) {
              var shiftUser = Utils.specifyTypeShift(int.parse(presenceData["shift"]));
              var absenMasuk = DateTime.parse(presenceData["login_presence"]);
              var absenKeluar = DateTime.parse(presenceData["login_presence"]); // sementara diisi ini dulu, baru diganti jamnya dan minutenya
              if (shiftUser == TypeShift.shiftPagi) {
                absenKeluar = Utils.customDateNotNow(absenMasuk, split(shiftPagi["jamKeluar"], true), split(shiftPagi["jamKeluar"], false));
                // if (DateTime.now().difference(DateTime.parse(presenceData['login_presence'])).inHours > 12) {
                if (DateTime.now().difference(Utils.customDate(split(shiftPagi["jamKeluar"], true), split(shiftPagi["jamKeluar"], false))).inMinutes > 5) {
                  // print("$shiftUser" " $absenKeluar");
                  await db.collection('presence').doc(doc.id).update({'$userID.logout_presence': absenKeluar.toString()});
                  // Update value in memory
                  presenceData['logout_presence'] = absenKeluar.toString();
                }
              } else {
                absenKeluar = Utils.customDateNotNow(absenMasuk, split(shiftSore["jamKeluar"], true), split(shiftSore["jamKeluar"], false));
                if (DateTime.now().difference(Utils.customDate(split(shiftSore["jamKeluar"], true), split(shiftSore["jamKeluar"], false))).inMinutes > 5) {
                  // print("$shiftUser" " $absenKeluar");
                  await db.collection('presence').doc(doc.id).update({'$userID.logout_presence': absenKeluar.toString()});
                  // Update value in memory
                  presenceData['logout_presence'] = absenKeluar.toString();
                }
              }
            }

            // Tambahkan data presensi ke listPresence
            listPresence?.add(presenceData);
          });
        }
        // Sorting berdasarkan login_presence descending (terbaru ke terlama)
        listPresence.sort((a, b) {
          var loginPresenceA = DateTime.parse(a['login_presence']);
          var loginPresenceB = DateTime.parse(b['login_presence']);
          return loginPresenceB.compareTo(loginPresenceA);
        });
      }

      // log("LIST PRESENCE : $listPresence");
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

  Future<void> updateFieldInPresenceCollection(String userID, String newValue) async {
    try {
      // Ambil semua dokumen dari koleksi 'presence'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('presence').get();

      // Iterasi melalui setiap dokumen
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Ambil data dari dokumen
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // print(data);
        // Cek jika dokumen memiliki field 'userID'
        if (data.containsKey(userID)) {
          // Update fieldName di dalam data jika userID sesuai
          // Ganti dengan userID yang sesuai
          data[userID]["userName"] = newValue;

          // Update dokumen di Firestore
          await doc.reference.update(data);

          print('User $newValue updated in document with ID ${doc.id}');
        }
      }

      print('Update selesai.');
    } catch (e) {
      print('Error updating field: $e');
    }
  }

  Future<void> updateFieldGajiInUsersCollection(String userID, Map<String, dynamic> newValue) async {
    try {
      // Ambil dokumen spesifik dari koleksi 'users'
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userID).get();

      // Cek jika dokumen ditemukan
      if (snapshot.exists) {
        // Ambil data dari dokumen
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Perbarui nilai gaji, lembur, dan potongan di dalam data
        data.putIfAbsent("gaji", () {
          return {
            "gaji": newValue['gaji'],
            "lembur": newValue['lembur'],
            "potongan": newValue['potongan'],
          };
        });
        // Update dokumen di Firestore
        await snapshot.reference.update(data);

        // print('User $userID updated in document with ID ${doc.id}');
        Utils.showToast(TypeToast.success, 'Update selesai.');
      } else {
        Utils.showToast(TypeToast.error, 'Data does not exist.');
      }
    } catch (e) {
      Utils.showToast(TypeToast.error, 'Error updating.');
    }
  }

  // get all `users` collection's documents
  Future<List<Map<String, dynamic>>?> getAllUser() async {
    List<Map<String, dynamic>>? listUsers;
    try {
      QuerySnapshot querySnapshot = await db.collection('users').get();
      listUsers = [];
      if (querySnapshot.docs.isNotEmpty) {
        // Iterasi melalui setiap dokumen
        for (var doc in querySnapshot.docs) {
          // Iterasi melalui setiap user di dalam dokumen
          Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
          listUsers.add(docData);
        }

        // Sorting berdasarkan login_presence descending (terbaru ke terlama)
        // listUsers.sort((a, b) {
        //   var loginPresenceA = DateTime.parse(a['login_presence']);
        //   var loginPresenceB = DateTime.parse(b['login_presence']);
        //   return loginPresenceB.compareTo(loginPresenceA);
        // });
      }
    } catch (e) {
      print("Error fetching getAllUser data: $e");
    }
    return listUsers;
  }
}
