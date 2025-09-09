import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../func/export.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    checkSession();
  }

  void checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() => isLoggedIn = token != null);
    checkAndClearExpiredSession(context);
    // clearSession(context);
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? HomePage() : LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  login(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      messageInfo(context, 'Veuillez remplir tous les champs.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final session = await postData("api/auth/login/", {
      'username': username,
      'password': password,
    });

    setState(() {
      isLoading = false;
    });

    if (session != null && session['token'] != null) {
      saveSession(session);
      navigatePage(context, HomePage());
    } else {
      messageInfo(context, 'Échec de la connexion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              navigatePage(
                context,
                Video(
                  videoUrl: "assets/images/MOTOSEKUR.mp4",
                  isNetwork: false,
                ),
              );
            },
            icon: Icon(CupertinoIcons.info),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: PopScope(
        canPop: false,
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(19.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Image.asset("assets/images/logo.png", height: 180),
                      SizedBox(height: 10),
                      // Text(
                      //   "MOTOSEKUR",
                      //   style: TextStyle(
                      //     fontSize: 35,
                      //     fontWeight: FontWeight.w800,
                      //     letterSpacing: -2,
                      //   ),
                      // ),
                      Text(
                        "Bienvenue, connectez-vous pour continuer",
                        style: TextStyle(
                          fontSize: 15,
                          color: const Color.fromARGB(255, 132, 132, 132),
                        ),
                      ),
                      SizedBox(height: 30),
                      inputZone(
                        usernameController,
                        'Pseudonyme (à utiliser pour la connexion)',
                      ),
                      inputZonePwd(passwordController, 'Mot de passe'),
                      SizedBox(height: 25),
                      isLoading
                          ? loading()
                          : btn(context, () => login(context), "CONNEXION"),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "N'avez vous pas une compte?",
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(width: 8),
                            Text("Identifiez-vous"),
                          ],
                        ),
                      ),
                    ],
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
