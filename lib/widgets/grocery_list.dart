import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  var _isLoading = true;
  List<GroceryItem> _groceryItems = [];
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) {
        return const NewItem();
      }),
    );
    if (newItem == null) return;

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      'flutter-shopping-list-ap-a21d3-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );
    http.delete(url);
  }

  void _loadItems() async {
    final url = Uri.https(
      'flutter-shopping-list-ap-a21d3-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      List<GroceryItem> loadedItems = [];
      for (final item in data.entries) {
        final category = categories.entries
            .firstWhere(
              (categoryItem) =>
                  categoryItem.value.title == item.value['category'],
            )
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget screenContent = ListView.builder(
      itemCount: _groceryItems.length,
      padding: const EdgeInsets.only(top: 15, left: 5),
      itemBuilder: (context, index) {
        final item = _groceryItems[index];
        return Dismissible(
          key: ValueKey(item),
          onDismissed: (direction) {
            _removeItem(item);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item removed from shopping list'),
                duration: Duration(seconds: 3),
              ),
            );
          },
          background: Container(
            color: Colors.red.withOpacity(0.7),
          ),
          child: ListTile(
            title: Text(
              _groceryItems[index].name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 15,
              ),
            ),
            leading: Container(
              height: 25,
              width: 25,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );

    if (_groceryItems.isEmpty) {
      screenContent = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No item is available. Try adding a new Item',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      screenContent = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error) {
      screenContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Oops!\nSomething went wrong.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 50),
              Text(
                'We\'re having some trouble. Please check your internet connection and try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: screenContent,
    );
  }
}
