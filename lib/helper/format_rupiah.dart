import 'package:intl/intl.dart';

String formatRupiah(int price) {
  var currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  return currencyFormatter.format(price);
}
