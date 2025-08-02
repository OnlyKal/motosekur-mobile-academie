import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../func/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfosPage extends StatefulWidget {
  const UserInfosPage({super.key});

  @override
  State<UserInfosPage> createState() => _UserInfosPageState();
}


class _UserInfosPageState extends State<UserInfosPage> {
  Map<String, dynamic> userInfos = {};

  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController usernameController;
  late TextEditingController dateNaissanceController;
  late TextEditingController lieuNaissanceController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    _initControllers();
    loadUserInfos();
  }

  void _initControllers() {
    nomController = TextEditingController();
    prenomController = TextEditingController();
    usernameController = TextEditingController();
    dateNaissanceController = TextEditingController();
    lieuNaissanceController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    addressController = TextEditingController();
  }

  Future<void> loadUserInfos() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userInfos = {
        "Photo de profil": prefs.getString('profile') ?? '',
        "Nom": prefs.getString('nom') ?? '',
        "Prénom": prefs.getString('prenom') ?? '',
        "Matricule": prefs.getString('matricule') ?? '',
        "Nom d'utilisateur": prefs.getString('username') ?? '',
        "Email": prefs.getString('email') ?? '',
        "Téléphone": prefs.getString('phone') ?? '',
        "Adresse": prefs.getString('address') ?? '',
        "Date de naissance": prefs.getString('date_naissance') ?? '',
        "Lieu de naissance": prefs.getString('lieu_naissance') ?? '',
        "Type d'utilisateur": prefs.getString('type_user') ?? '',
        "Validation Formation": (prefs.getBool('is_validated') ?? false)
            ? 'Oui'
            : 'Non',

        "Pièce d'identité": prefs.getString('photo_identite') ?? '',
      };

      nomController.text = prefs.getString('nom') ?? '';
      prenomController.text = prefs.getString('prenom') ?? '';
      usernameController.text = prefs.getString('username') ?? '';
      dateNaissanceController.text = prefs.getString('date_naissance') ?? '';
      lieuNaissanceController.text = prefs.getString('lieu_naissance') ?? '';
      phoneController.text = prefs.getString('phone') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      addressController.text = prefs.getString('address') ?? '';
    });
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    usernameController.dispose();
    dateNaissanceController.dispose();
    lieuNaissanceController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void showUpdateBottomSheet(int? userId) {
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Mettre à jour le motard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  inputZone(nomController, 'Nom'),
                  inputZone(prenomController, 'Prénom'),
                  inputZone(
                    dateNaissanceController,
                    'Date de naissance (YYYY-MM-DD)',
                  ),
                  inputZone(lieuNaissanceController, 'Lieu de naissance'),
                  inputZone(phoneController, 'Téléphone'),
                  inputZone(emailController, 'Email'),
                  inputZone(addressController, 'Adresse'),

                  const SizedBox(height: 40),
                  btn(context, () async {
                    final prefs = await SharedPreferences.getInstance();
                    if (formKey.currentState!.validate()) {
                      final response =
                          await patchData("api/auth/motards/$userId/update/", {
                            "nom": nomController.text,
                            "prenom": prenomController.text,
                            "username": usernameController.text,
                            "date_naissance": dateNaissanceController.text,
                            "lieu_naissance": lieuNaissanceController.text,
                            "phone": phoneController.text,
                            "email": emailController.text,
                            "address": addressController.text,
                          });

                      if (response != null) {
                        await prefs.setInt('id', response['data']['id']);
                        await prefs.setString(
                          'username',
                          response['data']['username'],
                        );
                        await prefs.setString(
                          'matricule',
                          response['data']['matricule'],
                        );
                        await prefs.setString(
                          'email',
                          response['data']['email'],
                        );
                        await prefs.setString(
                          'type_user',
                          response['data']['type_user'],
                        );
                        await prefs.setString('nom', response['data']['nom']);
                        await prefs.setString(
                          'prenom',
                          response['data']['prenom'],
                        );
                        await prefs.setString(
                          'date_naissance',
                          response['data']['date_naissance'],
                        );
                        await prefs.setString(
                          'lieu_naissance',
                          response['data']['lieu_naissance'],
                        );
                        await prefs.setString(
                          'phone',
                          response['data']['phone'],
                        );
                        await prefs.setString(
                          'address',
                          response['data']['address'],
                        );
                        await prefs.setString(
                          'photo_identite',
                          response['data']['photo_identite'] ?? '',
                        );
                        await prefs.setString(
                          'autre_piece',
                          response['data']['autre_piece'] ?? '',
                        );
                        await prefs.setString(
                          'profile',
                          response['data']['profile'] ?? '',
                        );
                        await prefs.setBool(
                          'is_validated',
                          response['data']['is_validated'] ?? false,
                        );
                        await loadUserInfos();
                        Navigator.pop(context);
                        messageInfo(
                          context,
                          "Informations mises à jour avec succès",
                        );
                      } else {
                        messageInfo(context, "Erreur lors de la mise à jour");
                      }
                    }
                  }, 'Mettre à jour'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainClr,
        leading: IconButton(
          onPressed: () => navigatePage(context, HomePage()),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: const Text(
          "MES INFORMATIONS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              final actions = {
                'logout': () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Voulez-vous vous déconnecter ?"),
                      action: SnackBarAction(
                        label: 'Oui',
                        onPressed: () {
                          clearSession(context);
                        },
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                },
                'edit': () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt("id");
                  if (userId != null) {
                    showUpdateBottomSheet(userId);
                  } else {
                    messageInfo(context, "Utilisateur non identifié");
                  }
                },
              };
              actions[value]?.call();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Éditer tilisateur'),
              ),
              const PopupMenuItem(value: 'logout', child: Text("Déconnecter")),
            ],
          ),

          const SizedBox(width: 0),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: heigth(context, 2),
          child: RefreshIndicator(
            onRefresh: loadUserInfos,
            child: Column(
              children: [
                SizedBox(
                  height: heigth(context, 1),
                  child: ListView.separated(
                    padding: EdgeInsets.only(bottom: 50),
                    itemCount: userInfos.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final key = userInfos.keys.elementAt(index);
                      final value = userInfos[key];
                      if (value.toString().contains("/media/profiles/")) {
                        return Column(
                          children: [
                            SizedBox(height: 15),
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: value.isNotEmpty
                                  ? NetworkImage(urlImage(value!))
                                  : const AssetImage('assets/images/logo.png')
                                        as ImageProvider,
                              child: GestureDetector(
                                onTap: () => navigatePage(
                                  context,
                                  UploadProfilePage(
                                    destination: UserInfosPage(),
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: const Color.fromARGB(
                                    132,
                                    0,
                                    0,
                                    0,
                                  ),
                                  child: Icon(
                                    Icons.photo_camera,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(height: 100),
                          ],
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (value.toString().contains('/media/'))
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => navigatePage(
                                      context,
                                      ViewImage(
                                        image: value,
                                        page: UserInfosPage(),
                                      ),
                                    ),
                                    child: const Text(
                                      "OUVRIR",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 3, 91, 163),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => navigatePage(
                                      context,
                                      UploadIDPage(
                                        destination: UserInfosPage(),
                                      ),
                                    ),
                                    child: const Text(
                                      "MODIFIER",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 3, 91, 163),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else if (value.toString().contains("Oui"))
                              Icon(Icons.check_circle, color: Colors.green)
                            else if (value.toString().contains("Non"))
                              Icon(Icons.cancel, color: Colors.red)
                            else
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    if (value.toString().contains(
                                      "MOTOSEKUR",
                                    )) {
                                      Clipboard.setData(
                                        ClipboardData(text: value),
                                      );
                                      messageInfo(context, "Copié");
                                    }
                                  },
                                  child: Text(
                                    value.toString(),
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
