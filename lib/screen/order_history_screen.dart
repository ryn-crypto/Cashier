import 'dart:convert';
import 'dart:io';
import 'package:cashier/helper/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../assets/colors.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orderHistory = [];

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/order_history.json';

      if (await File(filePath).exists()) {
        final content = await File(filePath).readAsString();
        setState(() {
          _orderHistory = jsonDecode(content);
        });
      } else {
        setState(() {
          _orderHistory = [];
        });
      }
    } catch (e) {
      print('Gagal memuat data riwayat pesanan: $e');
      setState(() {
        _orderHistory = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customColorScheme.background,
      appBar: AppBar(
        title: const Text(
          "Order History",
          style: TextStyle(
              color: Colors.black54, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _orderHistory.isEmpty
          ? const Center(
        child: Text("No order history found."),
      )
          : LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;
          final crossAxisCount = isWideScreen ? 2 : 1;

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: _orderHistory.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2,
            ),
            itemBuilder: (context, index) {
              final order = _orderHistory[index];
              final customerName = order['customerName'] ?? 'Unknown';
              final total = (order['total'] ?? 0).toInt();
              final timestamp = order['timestamp'] ?? '';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Customer: $customerName",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Total: ${formatRupiah(total)}"),
                        const SizedBox(height: 8),
                        Text("Date: $timestamp"),
                        const SizedBox(height: 8),
                        const Text(
                          "Items:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ..._buildOrderItems(order['orderItems']),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildOrderItems(List<dynamic>? items) {
    if (items == null || items.isEmpty) {
      return [const Text("No items found.")];
    }
    return items.map((item) {
      final title = item['title'] ?? 'Unknown';
      final quantity = item['quantity'] ?? 0;
      final price = item['price'] ?? 0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
            "$title x$quantity - ${formatRupiah(quantity * price)}"),
      );
    }).toList();
  }
}