import 'package:flutter/material.dart';

class CreditTransferPage extends StatefulWidget {
  @override
  _CreditTransferPageState createState() => _CreditTransferPageState();
}

class _CreditTransferPageState extends State<CreditTransferPage> {
  double userCredit = 0.0;
  String selectedProvider = 'Alfa';
  List<String> transferDetails = [];

  final double alfaTax = 0.14;
  final double mtcTax = 0.15;
  final double minCreditRequirement = 1.18;
  final List<double> allowedTransferAmounts = [0.5, 1, 1.5, 2, 2.5, 3];

  void calculateMaxTransfer() {
    double tax = (selectedProvider == 'Alfa') ? alfaTax : mtcTax;
    double remainingCredit = userCredit;
    double totalTransferableAmount = 0.0;
    int messageCount = 0;

    transferDetails.clear();

    if (remainingCredit < minCreditRequirement) {
      setState(() {
        transferDetails.add(
          'Insufficient credit. Your credit must be at least \$${minCreditRequirement.toStringAsFixed(2)} to make a transfer.',
        );
      });
      return;
    }

    // Process at least one transfer if the remaining credit meets requirements
    while (remainingCredit >= (allowedTransferAmounts[0] + tax) &&
        remainingCredit > minCreditRequirement) {
      double currentTransfer = allowedTransferAmounts.lastWhere(
            (amount) => (remainingCredit >= (amount + tax)),
        orElse: () => 0.0,
      );

      if (currentTransfer == 0.0) break;

      remainingCredit -= (currentTransfer + tax);
      totalTransferableAmount += currentTransfer;
      messageCount++;

      transferDetails.add(
        'Message $messageCount: Transferred \$${currentTransfer.toStringAsFixed(2)}, '
            'Tax: \$${tax.toStringAsFixed(2)}, Remaining Credit: \$${remainingCredit.toStringAsFixed(2)}',
      );
    }

    // Add summary messages
    if (messageCount == 0) {
      transferDetails.add(
        'No transfers were possible with the entered credit of \$${userCredit.toStringAsFixed(2)}.',
      );
    } else {
      transferDetails.add('Total transferable amount: \$${totalTransferableAmount.toStringAsFixed(2)}');
      transferDetails.add('Total messages sent: $messageCount');
      transferDetails.add('Remaining credit: \$${remainingCredit.toStringAsFixed(2)}');
    }

    // Update UI with the new transfer details
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Transfer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter your current credit (\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  userCredit = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedProvider,
              onChanged: (String? newValue) {
                setState(() {
                  selectedProvider = newValue!;
                });
              },
              items: ['Alfa', 'MTC (Touch)']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateMaxTransfer,
              child: const Text('Calculate Max Transferable Amount'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: transferDetails.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(
                        transferDetails[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
