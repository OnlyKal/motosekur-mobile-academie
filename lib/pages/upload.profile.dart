import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../func/export.dart';

class UploadProfilePage extends StatefulWidget {
  final destination;
  const UploadProfilePage({super.key, required this.destination});

  @override
  State<UploadProfilePage> createState() => _UploadProfilePageState();
}

class _UploadProfilePageState extends State<UploadProfilePage> {
  File? _image;
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 75);
    if (pickedFile == null) return;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Redimensionner',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Redimensionner',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        WebUiSettings(context: context),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _image = File(croppedFile.path);
        if (_image != null) {
          _uploadImage();
        }
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    setState(() => isLoading = true);
    final bytes = await _image!.readAsBytes();
    final base64Image = base64Encode(bytes);
    final fileExtension = _image!.path.split('.').last;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final upload = await patchData("api/auth/upload-profile/", {
        "profile": "data:image/$fileExtension;base64,$base64Image",
      });
      if (upload['profile'] != null) {
        messageInfo(context, "Profile modifié....");
        prefs.setString("profile", upload['profile']);
      } else {
        messageInfo(context, "Echec modification profile...");
      }
    } catch (e) {
      null;
    }
    setState(() => isLoading = false);
  }

  Future<Map<String, dynamic>> getInfos() async {
    final prefs = await SharedPreferences.getInstance();

    final username = prefs.getString('username') ?? '';
    final matricule = prefs.getString('matricule') ?? '';
    final nom = prefs.getString('nom') ?? '';
    final prenom = prefs.getString('prenom') ?? '';
    final isValidated = prefs.getBool('is_validated') ?? false;
    final profile = prefs.getString('profile') ?? '';

    return {
      "fullname": "$nom $prenom $username",
      "matricule": matricule,
      "status": isValidated,
      "profile": profile,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: heigth(context, 1),
          width: width(context, 1),
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 70),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                decoration: BoxDecoration(
                  color: mainClr.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Ajoutez ou modifier une photo de profil pour personnaliser votre compte. Cela permet aux autres de mieux vous reconnaître et rend votre expérience plus conviviale sur la plateforme.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color.fromARGB(255, 44, 44, 44),
                  ),
                ),
              ),
              SizedBox(height: 40),
              FutureBuilder(
                future: getInfos(),
                builder: (context, info) {
                  if (info.hasData) {
                    return Column(
                      children: [
                        Text(
                          info.data!['fullname'].toString().toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                          ),
                        ),
                        Text(
                          info.data?['matricule'],
                          style: TextStyle(
                            fontSize: 15,
                            color: const Color.fromARGB(255, 132, 132, 132),
                          ),
                        ),
                      ],
                    );
                  }
                  return Text("");
                },
              ),

              SizedBox(height: 20),
              if (_image != null)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 188, 188, 188),
                          width: 2,
                        ),
                        color: const Color.fromARGB(255, 213, 210, 210),
                        borderRadius: BorderRadius.circular(200),
                        image: DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: -140,
                      left: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: mainClr,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(66, 210, 210, 210),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(2),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors
                                  .black, // ou la couleur de fond que tu veux
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: GestureDetector(
                              onTap: () => showImageSourceSheet(context),
                              child: Icon(
                                Icons.camera_alt,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 216, 216, 216),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(200),
                      ),
                      child: Icon(Icons.person, size: 100, color: Colors.grey),
                    ),
                    Positioned(
                      bottom: 10,
                      right: -140,
                      left: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: mainClr,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(2),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: GestureDetector(
                              onTap: () => showImageSourceSheet(context),
                              child: Icon(
                                Icons.camera_alt,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 150),

              (_image != null)
                  ? (isLoading
                        ? Column(
                            children: [
                              loading(),
                              SizedBox(height: 3),
                              Text("TÉLÉCHARGEMENT..."),
                            ],
                          )
                        : btn(
                            context,
                            () => navigatePage(context, widget.destination),
                            "SUIVANT",
                          ))
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  void showImageSourceSheet(context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          color: mainClr,
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                icon: Icon(Icons.camera_alt, color: mainClr),
                label: Text("CAMERA", style: TextStyle(color: mainClr)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                icon: Icon(Icons.photo_library, color: mainClr),
                label: Text("GALERIE", style: TextStyle(color: mainClr)),
              ),
            ],
          ),
        );
      },
    );
  }
}
