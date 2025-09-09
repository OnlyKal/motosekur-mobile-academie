import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motosekur_academia/func/flaie.pay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../func/export.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController phoneCtrl = TextEditingController();
  bool isUsd = false;
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
    final response = await postData("api/auth/p/verification/", {
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
