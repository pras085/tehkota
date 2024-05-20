// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';
import 'package:teh_kota/app/widgets/page_controller.dart';
import '../db/databse_helper.dart';
import '../locator.dart';
import '../models/user.model.dart';
import '../services/camera.service.dart';
import '../services/ml_service.dart';

class AuthActionButton extends StatefulWidget {
  AuthActionButton({Key? key, required this.onPressed, required this.isLogin, required this.reload});
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  final MLService _mlService = locator<MLService>();
  final CameraService _cameraService = locator<CameraService>();

  final TextEditingController _userTextEditingController = TextEditingController(text: '');

  User? predictedUser;

  Future _signUp(context) async {
    DatabaseHelper _databaseHelper = DatabaseHelper.instance;
    List predictedData = _mlService.predictedData;
    String user = _userTextEditingController.text;
    User userToSave = User(
      user: user,
      modelData: predictedData,
    );
    await _databaseHelper.insert(userToSave);
    this._mlService.setPredictedData([]);
    // Get.offAll(PageViewController());
    Get.back();
    Get.back();
    Get.showSnackbar(GetSnackBar(
      message: "Berhasil mendaftarkan $user",
    ));
  }

  Future<User?> _predictUser() async {
    User? userAndPass = await _mlService.predict();
    return userAndPass;
  }

  Future onTap() async {
    try {
      bool faceDetected = await widget.onPressed();
      if (faceDetected) {
        if (widget.isLogin) {
          var user = await _predictUser();
          if (user != null) {
            this.predictedUser = user;
          }
        }
        PersistentBottomSheetController bottomSheetController = Scaffold.of(context).showBottomSheet((context) => signSheet(context));
        bottomSheetController.closed.whenComplete(() => widget.reload());
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[200],
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CAPTURE',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }

  signSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
                  child: Text(
                    'Welcome back, ' + predictedUser!.user + '.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: Text(
                      'User not found 😞',
                      style: TextStyle(fontSize: 20),
                    ))
                  : Container(),
          Container(
            child: Column(
              children: [
                !widget.isLogin
                    ? CustomTextFormField(
                        controller: _userTextEditingController,
                        title: "Your Name",
                      )
                    : Container(),
                SizedBox(height: 10),
                // widget.isLogin && predictedUser == null
                //     ? Container()
                //     : CustomTextFormField(
                //         controller: _passwordTextEditingController,
                //         title: "Password",
                //         isPassword: true,
                //       ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser != null
                    ? appButton(
                        text: 'LOGIN',
                        onPressed: () async {
                          // _signIn(context); IMplementasi Presensi
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    : !widget.isLogin
                        ? appButton(
                            text: 'SIGN UP',
                            onPressed: () async {
                              await _signUp(context);
                            },
                            icon: Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  appButton({required String text, required VoidCallback onPressed, required Icon icon}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }
}
