import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../func/export.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MotoPage extends StatefulWidget {
  const MotoPage({super.key});

  @override
  State<MotoPage> createState() => _MotoPageState();
}

class _MotoPageState extends State<MotoPage> {
  List<dynamic> motos = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadMotos();
  }

  Future<void> loadMotos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await getData("api/moto/my/");
      setState(() {
        motos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erreur : $e";
        isLoading = false;
      });
    }
  }

  Future<void> deleteMoto(int id) async {
    final result = await deleteData("api/moto/remove/$id/");
    if (result != null) {
      setState(() {
        motos.removeWhere((moto) => moto['id'] == id);
      });
    }
  }

  Future<void> editImage(int id, String base64Image) async {
    final response = await http.patch(
      Uri.parse("http://localhost:8000/api/moto/upload/$id/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"image": base64Image}),
    );
    if (response.statusCode == 200) {
      debugPrint("Image mise à jour avec succès.");
      await loadMotos(); // Recharge la liste après mise à jour
    } else {
      debugPrint("Échec de la mise à jour de l'image.");
    }
  }

  File? _image;
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
    try {
      await patchData("api/moto/upload/${motos[0]['id']}/", {
        "image": "data:image/$fileExtension;base64,$base64Image",
      });
      loadMotos();
    } catch (e) {
      null;
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => navigatePage(context, HomePage()),
          icon: Icon(CupertinoIcons.back),
        ),
        foregroundColor: Colors.white,
        backgroundColor: mainClr,
        title: const Text(
          "MA MOTO",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          motos.isEmpty
              ? SizedBox()
              : IconButton(
                  onPressed: () => showImageSourceSheet(context),
                  icon: Icon(Icons.photo_camera_outlined),
                ),
          SizedBox(width: 20),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : motos.isEmpty
          ? Container(
              padding: EdgeInsets.all(16),
              height: heigth(context, 1),
              width: width(context, 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/images/Motocross-amico.png", height: 140),
                  Text(
                    "Aucune moto trouvée.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Enregistrer votre moto. Ces informations nous aideront à collecter des données fiables pour votre Identification.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: motos.length,
              itemBuilder: (context, index) {
                final moto = motos[index];
                print(moto);
                return Column(
                  children: [
                    if (moto["image"] != null)
                      GestureDetector(
                        onTap: () {
                          navigatePage(
                            context,
                            ViewImage(image: moto["image"], page: MotoPage()),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              height: heigth(context, 0.3),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image:
                                      moto["image"] != null &&
                                          moto["image"]!.isNotEmpty
                                      ? NetworkImage(urlImage(moto["image"]!))
                                      : const AssetImage(
                                              'assets/images/logo.png',
                                            )
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ListTile(
                      leading: Icon(CupertinoIcons.forward, color: Colors.blue),
                      title: Text(
                        "MARQUE",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: Text(moto['brand']),
                    ),
                    Divider(height: 0),
                    ListTile(
                      leading: Icon(CupertinoIcons.forward, color: Colors.blue),
                      title: Text(
                        "MODELE",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: Text(moto['model']),
                    ),
                    Divider(height: 0),
                    ListTile(
                      leading: Icon(CupertinoIcons.forward, color: Colors.blue),
                      title: Text(
                        "NUMERO PLAQUE",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: Text(moto['plate_number']),
                    ),
                    Divider(height: 0),
                    ListTile(
                      leading: Icon(CupertinoIcons.forward, color: Colors.blue),
                      title: Text(
                        "NUMERO CHASSIS",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: Text(moto['chassis_number']),
                    ),
                    Divider(height: 0),
                  ],
                );
              },
            ),

      floatingActionButton: motos.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                final snackBar = SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Supprimer cette moto ?'),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              deleteMoto(motos[0]['id']);
                            },
                            child: Text(
                              'Oui',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  backgroundColor: Colors.black87,
                  duration: Duration(seconds: 5),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Icon(Icons.delete_outline_outlined, color: Colors.white),
            )
          : FloatingActionButton.extended(
              backgroundColor: mainClr,
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                int? id = prefs.getInt("id");
                addMoto(context, id!);
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Row(
                children: [
                  Text(
                    "IDENTIFIER VOTRE MOTO",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
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
                  setState(() {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  });
                },
                icon: Icon(Icons.camera_alt, color: mainClr),
                label: Text("CAMERA", style: TextStyle(color: mainClr)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  });
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

  void addMoto(BuildContext context, int ownerId) {
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final plateController = TextEditingController();
    final chassisController = TextEditingController();
    bool isloading = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "IDENTIFIER LA MOTO",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  inputZone(brandController, "La Marque (brand)"),
                  inputZone(modelController, "Le Modèle"),
                  inputZone(plateController, "Numéro de la Plaque"),
                  inputZone(chassisController, "Numéro du Châssis"),
                  const SizedBox(height: 20),
                  isloading == true
                      ? loading()
                      : btn(context, () async {
                          setState(() {
                            isloading = true;
                          });

                          final moto = await postData("api/moto/add/", {
                            "owner": ownerId,
                            "image": null,
                            "brand": brandController.text,
                            "model": modelController.text,
                            "plate_number": plateController.text,
                            "chassis_number": chassisController.text,
                            "created_at": DateTime.now()
                                .toUtc()
                                .toIso8601String(),
                          });

                          if (moto != null) {
                            loadMotos();
                            back(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(moto['message'])),
                            );
                            setState(() {
                              isloading = false;
                            });
                          }
                        }, "VALIDER"),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
