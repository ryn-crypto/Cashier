import 'package:cashier/screen/order_history_screen.dart';
import 'package:cashier/screen/order_screen.dart';
import 'package:cashier/screen/profile_screen.dart';
import 'package:cashier/screen/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'assets/colors.dart';
import 'components/MenuIcon.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cashier',
      theme: ThemeData.from(
        colorScheme: customColorScheme,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    const MenuScreen(),
    const OrderScreen(),
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  int _selectedIndex = 0;

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Menu", "icon": Icons.emoji_food_beverage},
    {"title": "Order", "icon": Icons.fastfood},
    {"title": "History", "icon": Icons.history},
    {"title": "Profile", "icon": Icons.person},
  ];

  final List<Map<String, dynamic>> orderItems = [
    {"title": "Burger", "quantity": 1, "price": 5.000},
    {"title": "Fries", "quantity": 2, "price": 2.500},
    {"title": "Soda", "quantity": 1, "price": 1.500},
    {"title": "Ice Cream", "quantity": 3, "price": 3.000},
  ];

  double _calculateSubTotal() {
    double subTotal = 0;
    for (var item in orderItems) {
      subTotal += (item['quantity'] as int) * (item['price'] as double);
    }
    return subTotal;
  }

  double _calculatePB(double subTotal) {
    return subTotal * 0.05;
  }

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double subTotal = _calculateSubTotal();
    double pb = _calculatePB(subTotal);
    return Scaffold(
      backgroundColor: customColorScheme.background,
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 12,
              height: MediaQuery.of(context).size.height,
              color: customColorScheme.surface,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final imageSize = constraints.maxWidth * 0.5;
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 16),
                          child: Image.asset(
                            'images/logo.png',
                            width: imageSize,
                            height: imageSize,
                          ),
                        ),
                        Column(
                          children: menuItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: const EdgeInsets.all(6),
                              child: MenuIcon(
                                active: _selectedIndex == index,
                                icon: item["icon"],
                                title: item["title"],
                                onTap: () {
                                  _onMenuTap(index);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Main Content Area
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}
