import 'package:flutter/material.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final _groceryItems = [];

  void addItem() async {
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
            setState(() {
              _groceryItems.removeAt(index);
            });
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Item removed from shopping list'),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () => setState(() {
                    _groceryItems.insert(index, item);
                  }),
                ),
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
              onPressed: addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: screenContent,
    );
  }
}
