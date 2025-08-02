import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../func/export.dart';

class MyPaiement extends StatefulWidget {
  const MyPaiement({super.key});

  @override
  State<MyPaiement> createState() => _MyPaiementState();
}

class _MyPaiementState extends State<MyPaiement> {
  List<dynamic> payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final paymentsData = await verificationPaiment(context);
      setState(() {
        payments = paymentsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        payments = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CupertinoActivityIndicator()));
    }

    if (payments.isEmpty) {
      return const Scaffold(body: Center(child: Text("No payments found.")));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainClr,
        leading: IconButton(
          onPressed: () => navigatePage(context, HomePage()),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: const Text(
          "",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final paymentData = payments[index];
          DateTime paymentDate = DateTime.parse(paymentData['payment_date']);
          String formattedDate =
              "${paymentDate.day}/${paymentDate.month}/${paymentDate.year} "
              "${paymentDate.hour}:${paymentDate.minute.toString().padLeft(2, '0')}";

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECU DE PAIEMENT FORMATION',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Montant payé: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${paymentData['amount']} ${paymentData['currency']}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  const Divider(height: 24),
                  const Text(
                    'Détails du paiement',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  infoRow('Nom du payeur', paymentData['payer_name'] ?? ''),
                  infoRow(
                    'Compte du payeur',
                    paymentData['payer_account'] ?? '',
                  ),
                  infoRow(
                    'Méthode de paiement',
                    paymentData['payment_method'] ?? '',
                  ),
                  infoRow(
                    'Référence banque',
                    paymentData['bank_reference'] ?? '',
                  ),
                  infoRow(
                    'ID de transaction',
                    paymentData['transaction_id'] ?? '',
                  ),
                  infoRow(
                    'Code confirmation',
                    paymentData['confirmation_code'] ?? 'N/A',
                  ),
                  infoRow(
                    'Frais',
                    "${paymentData['fee']} ${paymentData['currency']}",
                  ),
                  infoRow('Date paiement', formattedDate),
                  infoRow('Notes', paymentData['notes'] ?? ''),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}
