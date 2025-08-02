import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:motosekur_academia/func/_init.dart';
import '../pages/home.page.dart';

void showSuccessPayment(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("Succès", style: TextStyle(color: Colors.green))],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 15),
            Text(
              "Votre paiement de la formation a été effectué avec succès!",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          btn(context, () {
            navigatePage(context, HomePage());
          }, "RETOUR"),
        ],
      );
    },
  );
}

class FlexPaie {
  final BuildContext context;
  final Function(bool) setLoading;
  Timer? paymentTimer;
  FlexPaie({required this.context, required this.setLoading});

  Future<void> processPayment({
    required Map<dynamic, dynamic> user,
    required dynamic price,
    required String phone,
    required bool isUsd,
    required Future<void> Function() savePayment,
  }) async {
    final currency = isUsd ? "USD" : "CDF";
    final reference = "${generateID(true)}-${user['matricule']}";

    const urlPaiement = "https://backend.flexpay.cd/api/rest/v1/paymentService";
    setLoading(true);

    final response = await http.post(
      Uri.parse(urlPaiement),
      headers: {'Content-Type': 'application/json', 'Authorization': tokenApi},
      body: jsonEncode({
        "merchant": "NEPAA",
        "type": "1",
        "phone": phone,
        "reference": reference,
        "amount": isUsd ? price['montant_usd'] : price['montant_cdf'],
        "currency": currency,
        "callbackUrl": "https://abcd.efgh.cd",
      }),
    );

    final data = json.decode(response.body);

    if (data['code'] != "0") {
      setLoading(false);
      messageInfo(context, "Erreur lors de l'initiation du paiement.");
      return;
    }

    final String orderNumber = data['orderNumber'];
    int attemptCount = 0;
    const int maxAttempts = 10;

    paymentTimer = Timer.periodic(Duration(seconds: 4), (timer) async {
      attemptCount++;

      try {
        final res = await http.get(
          Uri.parse(
            "https://backend.flexpay.cd/api/rest/v1/check/$orderNumber",
          ),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': tokenApi,
          },
        );

        final checkData = json.decode(res.body);

        if (checkData['code'] == "0") {
          final status = checkData['transaction']['status'];

          if (status == "0") {
            timer.cancel();
            await savePayment();
            messageInfo(context, "Paiement confirmé !");
            setLoading(false);
            showSuccessPayment(context);
          } else if (status == "1") {
            timer.cancel();
            setLoading(false);
            messageInfo(context, "La transaction a échoué.");
          }
        }
      } catch (e) {
        print("Erreur check paiement: $e");
      }

      if (attemptCount >= maxAttempts) {
        timer.cancel();
        setLoading(false);
        messageInfo(
          context,
          "Paiement non confirmé après plusieurs tentatives.",
        );
      }
    });
  }
}
