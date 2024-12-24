import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../assets/colors.dart';
import '../components/ProductCard.dart';
import '../model/menu_item.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedCategoryIndex = 0;
  late List<MenuItem> menuItems;
  List<MenuItem> filteredItems = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Food',
    'Desert',
    'Coffee',
    'Soft Drink',
    'Snack',
  ];

  @override
  void initState() {
    super.initState();
    _loadMenuData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuData() async {
    try {
      final String jsonString = await rootBundle.loadString('data/menu.json');
      setState(() {
        menuItems = parseMenu(jsonString);
        filteredItems = menuItems;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading menu data: $e");
    }
  }

  void filterMenu() {
    final query = _searchController.text.toLowerCase();
    String selectedCategory = categories[_selectedCategoryIndex];

    setState(() {
      filteredItems = menuItems.where((item) {
        final matchesCategory = _selectedCategoryIndex == 0 ||
            item.category == selectedCategory;
        final matchesSearch = item.name.toLowerCase().contains(query);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged() {
    filterMenu();
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      filterMenu();
    });
  }

  Widget _buildCategoryChip(String label, bool isSelected, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          _onCategorySelected(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: customColorScheme.background,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: customColorScheme.onBackground,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for food, coffee, etc',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories
                          .asMap()
                          .entries
                          .map((entry) => _buildCategoryChip(
                        entry.value,
                        _selectedCategoryIndex == entry.key,
                        entry.key,
                      ))
                          .toList(),
                    ),
                  ),
                ),

                // Product Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ProductCard(
                          title: item.name,
                          price: 'Rp ${item.price}',
                          image: item.imageUrl,
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}