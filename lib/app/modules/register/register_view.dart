import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:teh_kota/app/modules/register/register_controller.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/custom_appbar.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';
import 'package:teh_kota/app/widgets/register_face_widget.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(RegisterController());
    return Obx(() {
      return WillPopScope(
        onWillPop: () {
          if (controller.viewType.value == ViewType.create) {
            controller.viewType.value = ViewType.list;
            return Future.value(false);
          } else {
            Get.back();
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(AppColor.colorBgGray),
          body: SafeArea(
            child: SizedBox(
              width: Get.width,
              height: Get.height,
              child: !controller.loading.value
                  ? controller.viewType.value == ViewType.create
                      ? createWidget(context)
                      : listWidget()
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget listWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Obx(() {
          return CustomAppBar(
            customBody: SizedBox(
              width: Get.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!Utils.isAdmin.value)
                    InkWell(
                      onTap: () => Get.back(),
                      child: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: SvgPicture.asset(
                            "assets/ic_back_button.svg",
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: CustomText(
                      "Data Karyawan",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      textAlign: Utils.isAdmin.value ? TextAlign.left : TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.viewType.value = ViewType.create;
                    },
                    child: SvgPicture.asset("assets/ic_add_karyawan.svg"),
                  )
                ],
              ),
            ),
          );
        }),
        Expanded(
          child: StreamBuilder(
            stream: controller.firestore.getUsers(),
            builder: (context, snapshot) {
              // check our connection (loading|error)
              if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error fetching data: ${snapshot.data}');
              } else if (snapshot.hasData && snapshot.data?.docs.isEmpty == true) {
                return Container(
                  width: Get.width,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        "assets/ic_no_data.svg",
                      ),
                      const SizedBox(height: 12),
                      const CustomText(
                        "Tidak ada data",
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ],
                  ),
                );
              }
              // `data?.docs` return a [List<QueryDocumentSnapshot>]
              // we're going to return a [ListView.builder] with those documents data
              final documents = snapshot.data?.docs;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: documents?.length,
                  itemBuilder: (context, index) {
                    print("LENGTH : ${documents?.length}");
                    // var res = Utils.specifyTypeStatus(int.tryParse(listPresence["status"]));
                    return Container(
                      margin: EdgeInsets.only(top: index == 0 ? 0 : 16),
                      padding: const EdgeInsets.all(12),
                      width: Get.width,
                      // height: 48,
                      decoration: const BoxDecoration(
                        color: Color(AppColor.colorWhite),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/ic_profile.svg",
                                height: 24,
                                width: 24,
                              ),
                              Utils.gapHorizontal(6),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 150),
                                child: CustomText(
                                  documents?[index]['name'] ?? "",
                                  fontSize: 12,
                                ),
                              ),
                              Utils.gapHorizontal(6),
                              const Spacer(),
                              if (Utils.isAdmin.value)
                                InkWell(
                                  onTap: () {},
                                  child: const RotatedBox(
                                    quarterTurns: 45,
                                    child: Icon(Icons.more_vert),
                                  ),
                                )
                              else
                                const SizedBox.shrink(), // Todo Developement
                              Utils.gapHorizontal(6),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget createWidget(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          customBody: SizedBox(
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => controller.viewType.value = ViewType.list,
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: SvgPicture.asset(
                        "assets/ic_back_button.svg",
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: CustomText(
                    "Tambah Karyawan",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              InkWell(
                onTap: () async {
                  var res = await Utils.showAlertDialog(context, "Apakah anda yakin ingin menghapus database ?");
                  if (res) {
                    try {
                      await controller.dbHelper.deleteAll();
                      await controller.firestore.deleteCollection('users');
                      Utils.showToast(TypeToast.success, "Berhasil menghapus database!");
                    } catch (e) {
                      print('Error deleting collection: $e');
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(AppColor.colorLightGrey),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Delete Database',
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.delete, color: Colors.black)
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => const RegisterFace()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(AppColor.colorGreen),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(AppColor.colorGreen).withOpacity(0.5),
                        blurRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Tambah Karyawan',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.person_add, color: Colors.white)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
