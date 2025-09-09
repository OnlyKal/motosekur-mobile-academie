import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../func/export.dart';

class UploadIDPage extends StatefulWidget {
  final destination;
  const UploadIDPage({super.key, required this.destination});

  @override
  State<UploadIDPage> createState() => _UploadIDPageState();
}

class _UploadIDPageState extends State<UploadIDPage> {
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
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
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
      final upload = await patchData("api/auth/upload-id/", {
        "photo_identite": "data:image/$fileExtension;base64,$base64Image",
      });
      if (upload['photo_identite'] != null) {
        messageInfo(context, "ID modifié....");
        prefs.setString("photo_identite", upload['photo_identite']);
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

  String? profileUrl;
  @override
  void initState() {
    _loadProfileUrl();
    super.initState();
  }

  Future<void> _loadProfileUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileUrl = prefs.getString('profile');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: profileUrl != null && profileUrl!.isNotEmpty
                ? NetworkImage(urlImage(profileUrl!))
                : AssetImage('assets/images/logo.png') as ImageProvider,
          ),
          SizedBox(width: 10),
        ],
        title: FutureBuilder(
          future: getInfos(),
          builder: (context, info) {
            if (info.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.data!['fullname'].toString().toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    info.data?['matricule'],
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color.fromARGB(255, 132, 132, 132),
                    ),
                  ),
                ],
              );
            }
            return Text("");
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: heigth(context, 1),
          width: width(context, 1),
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: mainClr.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Ajoutez ou modifier une pièce d'identité (carte d’électeur ou passeport) pour renforcer la crédibilité de votre compte.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color.fromARGB(255, 44, 44, 44),
                  ),
                ),
              ),

              SizedBox(height: 20),
              if (_image != null)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 300,
                      width: width(context, 1),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 188, 188, 188),
                          width: 2,
                        ),
                        color: const Color.fromARGB(255, 213, 210, 210),
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 0,
                      left: 300,
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
                )
              else
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 300,
                      width: width(context, 1),

                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 240, 240, 240),
                        border: Border.all(
                          color: const Color.fromARGB(255, 216, 216, 216),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.card_membership,
                        size: 100,
                        color: const Color.fromARGB(255, 197, 197, 197),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 0,
                      left: 300,
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
              SizedBox(height: 100),

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
