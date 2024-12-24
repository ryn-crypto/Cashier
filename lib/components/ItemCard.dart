import 'package:flutter/material.dart';

import '../helper/format_rupiah.dart';

class ItemCard extends StatelessWidget {
  final int index;
  final String title;
  final int quantity;
  final int price;

  const ItemCard({
    super.key,
    required this.index,
    required this.title,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = price * quantity;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Text(
            index.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          formatRupiah(price),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'x $quantity',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            Text(
              formatRupiah(totalPrice),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}