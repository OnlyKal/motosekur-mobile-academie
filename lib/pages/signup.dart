import 'package:flutter/material.dart';
import '../func/export.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController nom = TextEditingController();
  final TextEditingController prenom = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController dateNaissance = TextEditingController();
  final TextEditingController lieuNaissance = TextEditingController();
  final TextEditingController address = TextEditingController();

  bool isLoading = false;
  Future<void> register(BuildContext context) async {
    if (username.text.trim().isEmpty ||
        password.text.trim().isEmpty ||
        nom.text.trim().isEmpty ||
        prenom.text.trim().isEmpty ||
        phone.text.trim().isEmpty ||
        dateNaissance.text.trim().isEmpty ||
        lieuNaissance.text.trim().isEmpty ||
        address.text.trim().isEmpty) {
      messageInfo(context, 'Veuillez remplir tous les champs obligatoires.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final session = await postData("api/auth/register/", {
      'username': username.text.trim(),
      'password': password.text.trim(),
      'nom': nom.text.trim(),
      'prenom': prenom.text.trim(),
      'email': "motosekur@gmail.com",
      'phone': phone.text.trim(),
      'date_naissance': dateNaissance.text.trim(),
      'lieu_naissance': lieuNaissance.text.trim(),
      'address': address.text.trim(),
      'photo_identite': null,
      'piece_identite': null,
      'profile': null,
    });

    setState(() {
      isLoading = false;
    });

    if (session != null && session['token'] != null) {
      saveSession(session);
      navigatePage(
        context,
        UploadProfilePage(destination: UploadIDPage(destination: HomePage())),
      );
      messageInfo(context, "Compte créé avec succès.");
    } else {
      messageInfo(context, 'Erreur lors de l’enregistrement.');
    }
  }

  @override
  void initState() {
    prenom.addListener(() {
      username.text = generateUsername(prenom.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    prenom.dispose();
    username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 80),
            Image.asset("assets/images/logo.png", height: 90),
            SizedBox(height: 5),

            Text(
              "Bienvenue, connectez-vous pour continuer",
              style: TextStyle(
                fontSize: 15,
                color: const Color.fromARGB(255, 132, 132, 132),
              ),
            ),
            SizedBox(height: 20),
            inputZone(nom, 'Nom'),
            inputZone(prenom, 'Prénom'),
            const SizedBox(height: 20),
            Text(
              "Champs trés important",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            inputZone(username, "Pseudonyme (à utiliser pour la connexion)"),
            inputZonePwd(password, 'Mot de passe'),
            const SizedBox(height: 20),
            inputDatePickerZone(context, dateNaissance, 'Date de naissance'),
            inputZone(lieuNaissance, 'Lieu de naissance'),
            inputZone(phone, 'Téléphone'),
            inputZone(address, 'Adresse'),
            const SizedBox(height: 20),
            isLoading
                ? loading()
                : btn(context, () => register(context), "SUIVANT"),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => navigatePage(context, LoginPage()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Vous avez déjà une compte?",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(width: 8),
                  Text("Connectez-vous"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
