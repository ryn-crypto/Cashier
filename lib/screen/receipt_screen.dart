import 'dart:convert';
import 'dart:io';

import 'package:cashier/main.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../assets/colors.dart';
import '../helper/format_rupiah.dart';

class ReceiptScreen extends StatelessWidget {
  final String customerName;
  final double subTotal;
  final double pb;
  final double total;
  final List<Map<String, dynamic>> orderItems;

  const ReceiptScreen({
    super.key,
    required this.customerName,
    required this.subTotal,
    required this.pb,
    required this.total,
    required this.orderItems,
  });

  void _saveOrderHistory() async {
    final orderData = {
      'customerName': customerName,
      'subTotal': subTotal,
      'pb': pb,
      'total': total,
      'orderItems': orderItems,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/order_history.json';

      List<dynamic> existingData = [];
      if (await File(filePath).exists()) {
        final content = await File(filePath).readAsString();
        existingData = jsonDecode(content);
      }

      existingData.add(orderData);

      await File(filePath).writeAsString(jsonEncode(existingData), flush: true);

      print('Data pesanan berhasil disimpan ke file: $filePath');
    } catch (e) {
      print('Gagal menyimpan data pesanan: $e');
    }
  }

  void _handlePayment(BuildContext context, String paymentMethod) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Payment Confirmation"),
          content: Text("You have selected $paymentMethod. Do you want to proceed?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _proceedWithPayment(context, paymentMethod);
              },
              child: const Text("Proceed"),
            ),
          ],
        );
      },
    );
  }

  void _proceedWithPayment(BuildContext context, String paymentMethod) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Payment Process"),
          content: Text("Proceeding with $paymentMethod payment. Please follow the instructions."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Thank You!"),
                      content: const Text("Terimakasih sudah memesan."),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            _saveOrderHistory();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            );
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Receipt",
            style: TextStyle(color: customColorScheme.onSecondary)),
        backgroundColor: customColorScheme.secondary,
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          color: customColorScheme.surface,
          width: 500, // Lebar tetap 500
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer: $customerName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 19),
                  const Text(
                    'Order Details:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildOrderItemsList(),
                  const Divider(
                    color: Colors.black,
                    thickness: .5,
                  ),
                  const SizedBox(height: 20),
                  _buildPriceRow('Sub Total:', subTotal.toInt()),
                  _buildPriceRow('PB (5%):', pb.toInt()),

                  const Divider(
                    color: Colors.black,
                    thickness: 1.5,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Total: ${formatRupiah(total.toInt())}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Button to go back or proceed
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Tampilkan modal dengan daftar metode pembayaran
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Select Payment Method"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.qr_code),
                                    title: const Text("QRIS"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _handlePayment(context, "QRIS");
                                    },
                                  ),
                                  // Bank
                                  ListTile(
                                    leading: Icon(Icons.account_balance),
                                    title: const Text("Bank Transfer"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _handlePayment(context, "Bank Transfer");
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customColorScheme.primary,
                      ),
                      child: const Text("Select Payment Method", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(formatRupiah(amount), style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildOrderItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: orderItems.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  '${item['title']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text("x${item['quantity']}"),
              ),

              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatRupiah((item['quantity']) * (item['price']).toInt()),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

            ],
          ),
        );
      }).toList(),
    );
  }
}
