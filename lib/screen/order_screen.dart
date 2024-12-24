import 'package:cashier/screen/receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../assets/colors.dart';
import '../components/ItemCard.dart';
import '../components/ProductCard.dart';
import '../helper/format_rupiah.dart';
import '../model/menu_item.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool showOnlyButton = true;
  int _selectedCategoryIndex = 0;
  late List<MenuItem> menuItems;
  bool isLoading = true;

  final List<String> categories = [
    'All',
    'Food',
    'Desert',
    'Coffee',
    'Soft Drink',
    'Snack',
  ];

  final List<Map<String, dynamic>> orderItems = [];
  final Set<int> expandedItems = {};

  void _addItemToOrder(MenuItem item) {
    setState(() {
      final existingItemIndex =
          orderItems.indexWhere((orderItem) => orderItem['title'] == item.name);

      if (existingItemIndex != -1) {
        orderItems[existingItemIndex]['quantity'] += 1;
      } else {
        orderItems.add({
          'title': item.name,
          'quantity': 1,
          'price': item.price,
        });
      }
    });
  }

  void _toggleExpandItem(int index) {
    setState(() {
      if (expandedItems.contains(index)) {
        expandedItems.clear();
      } else {
        expandedItems.clear();
        expandedItems.add(index);
      }
    });
  }

  void _updateItemQuantity(int index, int delta) {
    setState(() {
      orderItems[index]['quantity'] += delta;
      if (orderItems[index]['quantity'] <= 0) {
        orderItems.removeAt(index);
        expandedItems.remove(index);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMenuData();
  }

  Future<void> _loadMenuData() async {
    try {
      final String jsonString = await rootBundle.loadString('data/menu.json');
      setState(() {
        menuItems = parseMenu(jsonString);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading menu data: $e");
    }
  }

  List<MenuItem> getFilteredMenu() {
    if (_selectedCategoryIndex == 0) return menuItems;
    String selectedCategory = categories[_selectedCategoryIndex];
    return menuItems
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  double get subTotal =>
      orderItems.fold(0, (sum, item) => sum + item['quantity'] * item['price']);

  double get pb => subTotal * 0.05;

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(label),
                selected: _selectedCategoryIndex == index,
                onSelected: (_) => _onCategorySelected(index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<MenuItem> filteredMenu) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3 / 4,
          ),
          itemCount: filteredMenu.length,
          itemBuilder: (context, index) {
            final item = filteredMenu[index];
            return ProductCard(
              title: item.name,
              price: formatRupiah(item.price),
              image: item.imageUrl,
              onTap: () => {_addItemToOrder(item), showOnlyButton = false},
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      color: customColorScheme.surface,
      width: MediaQuery.of(context).size.width / 4,
      child: Column(
        children: [
          _buildOrderHeader(),
          _buildOrderList(),
          _buildOrderTotal(),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Order ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                TextSpan(
                  text: 'Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_fullscreen,
              color: customColorScheme.onSecondary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                showOnlyButton = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return Expanded(
      child: ListView.builder(
        itemCount: orderItems.length,
        itemBuilder: (context, index) {
          final item = orderItems[index];
          final isExpanded = expandedItems.contains(index);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _toggleExpandItem(index),
                  child: ItemCard(
                    index: index,
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ),
                ),
                if (isExpanded)
                  Container(
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 25.0),
                    decoration: BoxDecoration(
                      color: customColorScheme.onSurface,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => _updateItemQuantity(index, -1),
                          icon: const Icon(Icons.remove,
                              size: 13, color: Colors.white),
                        ),
                        Text(
                          '${item['quantity']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _updateItemQuantity(index, 1),
                          icon: const Icon(Icons.add,
                              size: 13, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderTotal() {
    final price = subTotal + pb;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildPriceRow('Sub Total:', subTotal.toInt()),
          _buildPriceRow('PB (5%):', pb.toInt()),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (orderItems.isNotEmpty) {
                showOrderSummaryModal(
                  context,
                  subTotal: subTotal,
                  pb: pb,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: customColorScheme.primary,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              'Total: ${formatRupiah(price.toInt())}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(formatRupiah(amount)),
      ],
    );
  }

  void showOrderSummaryModal(BuildContext context,
      {required double subTotal, required double pb}) {
    final total = subTotal + pb;
    final TextEditingController customerNameController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Order Summary"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: customerNameController,
                  decoration: const InputDecoration(
                    labelText: "Customer Name",
                    hintText: "Enter customer's name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPriceRow('Sub Total:', subTotal.toInt()),
                _buildPriceRow('PB (5%):', pb.toInt()),
                const SizedBox(height: 20),
                Text(
                  'Total: ${formatRupiah(total.toInt())}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text("Close",
                  style: TextStyle(color: customColorScheme.onSurface)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: customColorScheme.primary,
              ),
              onPressed: () {
                final customerName = customerNameController.text;
                if (customerName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a customer name"),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop(); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptScreen(
                      customerName: customerName,
                      subTotal: subTotal,
                      pb: pb,
                      total: total,
                      orderItems: orderItems,
                    ),
                  ),
                );
              },
              child: Text("Proceed",
                  style: TextStyle(color: customColorScheme.background)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<MenuItem> filteredMenu = getFilteredMenu();

    return Scaffold(
      backgroundColor: customColorScheme.background,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySelector(),
                _buildProductGrid(filteredMenu),
              ],
            ),
          ),
          if (!showOnlyButton) _buildOrderSummary(),
        ],
      ),
      floatingActionButton: showOnlyButton
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  backgroundColor: customColorScheme.onSurface,
                  onPressed: () {
                    setState(() {
                      showOnlyButton = false;
                    });
                  },
                  heroTag: 'fab1',
                  child: const Icon(Icons.fullscreen),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    if (orderItems.isNotEmpty) {
                      showOrderSummaryModal(
                        context,
                        subTotal: subTotal,
                        pb: pb,
                      );
                    }
                  },
                  heroTag: 'fab2',
                  child: const Icon(Icons.navigate_next),
                ),
              ],
            )
          : null,
    );
  }
}
