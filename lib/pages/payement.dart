import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:motosekur_academia/func/flaie.pay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../func/export.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController phoneCtrl = TextEditingController();
  bool isUsd = true;
  Timer? paymentTimer;
  bool isLoading = false;

  String? _validateMobileNumber(String? value) {
    String phone = "243$value";

    if (phone.isEmpty) {
      return 'Veuillez saisir un numéro mobile';
    }
    if (!phone.startsWith('243')) {
      return 'Le numéro doit commencer par 243';
    }
    if (phone.length < 12) {
      return 'Le numéro est trop court';
    }
    return null;
  }

  // Future<void> payementFlex() async {
  //   final user = await getInfos();
  //   final price = await currentP();
  //   const String urlPaiement =
  //       "https://backend.flexpay.cd/api/rest/v1/paymentService";
  //   setState(() => isLoading = true);
  //   final response = await http.post(
  //     Uri.parse(urlPaiement),
  //     headers: {'Content-Type': 'application/json', 'Authorization': tokenApi},
  //     body: jsonEncode({
  //       "merchant": "NEPAA",
  //       "type": "1",
  //       "phone": "243${phonCtrl.text}",
  //       "reference": "${generateID(true)}-${user['matricule']}",
  //       "amount": price['montant'],
  //       "currency": isUsd ? "USD" : "CDF",
  //       "callbackUrl": "https://abcd.efgh.cd",
  //     }),
  //   );

  //   final data = json.decode(response.body);

  //   if (data['code'] == "0") {
  //     int attemptCount = 0;
  //     const int maxAttempts = 10;
  //     paymentTimer = Timer.periodic(Duration(seconds: 4), (timer) async {
  //       attemptCount++;
  //       final result = await checkPaymentBilling(data['orderNumber']);
  //       if (result) {
  //         timer.cancel();
  //       } else if (attemptCount >= maxAttempts) {
  //         timer.cancel();
  //         setState(() => isLoading = false);
  //         messageInfo(
  //           context,
  //           "Paiement non confirmé après plusieurs tentatives.",
  //         );
  //       }
  //     });
  //   } else {
  //     messageInfo(context, "Erreur lors de l'initiation du paiement.");
  //   }
  // }

  // Future<bool> checkPaymentBilling(String orderNumber) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('https://backend.flexpay.cd/api/rest/v1/check/$orderNumber'),
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Authorization': tokenApi,
  //       },
  //     );

  //     final data = json.decode(response.body);

  //     if (data['code'] == "0") {
  //       final status = data['transaction']['status'];
  //       if (status == "0") {
  //         await saveLocalPayment();
  //         messageInfo(context, "Paiement confirmé !");
  //         return true;
  //       } else if (status == "1") {
  //         messageInfo(context, "La transaction a échoué.");
  //         setState(() => isLoading = false);
  //         return true;
  //       }
  //     }
  //   } catch (e) {
  //     print("Erreur dans checkPaymentBilling: $e");
  //   }
  //   return false;
  // }

  Future<void> startPayment() async {
    final userMap = await getInfos();
    final priceMap = await currentP();

    final paie = FlexPaie(
      context: context,
      setLoading: (value) => setState(() => isLoading = value),
    );

    await paie.processPayment(
      user: userMap,
      price: priceMap,
      phone: "243${phoneCtrl.text}",
      isUsd: isUsd,
      savePayment: () => saveLocalPayment(userMap, priceMap),
    );
  }

  Future<void> saveLocalPayment(Map user, dynamic price) async {
    final response = await postData("api/payment/verification/", {
      "owner": user['id'],
      "transaction_id": generateID(true),
      "payment_status": "success",
      "amount": isUsd ? price['montant_usd'] : price['montant_cdf'],
      "motard_matricule": user['matricule'],
      "currency": isUsd ? "USD" : "CDF",
      "payment_date": DateTime.now().toIso8601String(),
      "payer_name": user['fullname'],
      "payer_account": phoneCtrl.text,
      "payment_method": "mobile",
      "bank_reference": "MOBILE TRANSACTION",
      "order_id": generateID(false),
      "signature": generateID(false),
    });

    if (response['status'] != "success") {
      messageInfo(context, "Erreur lors de la sauvegarde du paiement !");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    phoneCtrl.dispose();
    paymentTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainClr,
        leading: IconButton(
          onPressed: () => back(context),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          "EFFECTUER UN PAIEMENT",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Veuillez entrer votre numéro de téléphone à partir duquel le montant du paiement sera prélevé.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Switch(
                    padding: EdgeInsets.all(0),
                    value: isUsd,
                    onChanged: (value) {
                      setState(() {
                        isUsd = !isUsd;
                      });
                    },
                  ),
                  Text(
                    isUsd == true ? "USD 🇺🇸" : "CDF 🇨🇩",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Numéro Mobile (ex: 243xxxxxxxxx)',
                  border: OutlineInputBorder(),
                  prefixText: '243',
                ),
                validator: _validateMobileNumber,
              ),
              SizedBox(height: 5),

              Row(
                children: [
                  Icon(CupertinoIcons.info, size: 13, color: Colors.blue),
                  SizedBox(width: 3),
                  InkWell(
                    onTap: () async {
                      SharedPreferences user =
                          await SharedPreferences.getInstance();
                      String? phone = user.getString("phone");

                      if (phone != null && phone.length >= 9) {
                        String newphone = phone.substring(phone.length - 9);
                        phoneCtrl.text = newphone.toString();
                        setState(() {});
                      } else {
                        messageInfo(
                          "Numéro de téléphone invalide ou trop court.",
                          context,
                        );
                      }
                    },
                    child: Text(
                      "Utilisez votre numéro enregistré.",
                      style: TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              isLoading == true
                  ? loading()
                  : btn(context, () {
                      if (_formKey.currentState!.validate()) {
                        startPayment();
                      }
                    }, "VALIDER"),
            ],
          ),
        ),
      ),
    );
  }
}
