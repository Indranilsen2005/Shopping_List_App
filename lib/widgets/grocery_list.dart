import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  void addItem() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) {
        return const NewItem();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        itemCount: groceryItems.length,
        padding: const EdgeInsets.only(top: 15, left: 5),
        itemBuilder: (context, index) => ListTile(
          title: Text(
            groceryItems[index].name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 15,
            ),
          ),
          leading: Container(
            height: 25,
            width: 25,
            color: groceryItems[index].category.color,
          ),
          trailing: Text(
            groceryItems[index].quantity.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
