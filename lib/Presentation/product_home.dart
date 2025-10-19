import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:item_registration/Core/core.dart';
import 'package:item_registration/Infrastructure/db_functions.dart';
import 'package:item_registration/Model/item_category_model.dart';
import 'package:item_registration/Model/item_model.dart';
import 'package:item_registration/Presentation/login_screen.dart';
import 'package:item_registration/main.dart';

class ScreenProductHome extends StatelessWidget {
  ScreenProductHome({super.key});
  final itemCategoryController = TextEditingController();
  String? selectedItemCategory;
  final itemNameController = TextEditingController();
  final itemMrpController = TextEditingController();
  final itemSaleRateController = TextEditingController();
  final _formItemCategory = GlobalKey<FormState>();
  final _formItem = GlobalKey<FormState>();
  int itemCategoryId = 0;
  int itemId = 0;
  @override
  Widget build(BuildContext context) {
    final Future<void> _loadData = Future(() async {
  await getAllItems();
  
});

    return FutureBuilder(
      future: _loadData,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.lightGreen,
            title: Text('Welcome <Name>', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainApp()),
  (route) => false,
                  );
                },
              )
            ],

          ),
          body: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .8,
                child: ValueListenableBuilder(
                  valueListenable: itemNotifier,
                  builder: (context, List<ItemModel> newItemList, _) {
                    return ListView.separated(
                      itemBuilder: (context, index) {
                        var itemData = newItemList[index];
                        return ListTile(
                          leading: Text('${index + 1}'.toString()),
                          title: Text(itemData.itemName),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  Text('MRP: ${itemData.itemMrp}'),
                                  SizedBox(width: 10),
                                  Text('Sale Rate: ${itemData.itemSaleRate}'),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(getItemCategory(itemData.itemCategoryID)),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      ItemModel i = ItemModel(
                                        itemId: itemData.itemId,
                                        itemCategoryID: itemData.itemCategoryID,
                                        itemName: itemData.itemName,
                                        itemMrp: itemData.itemMrp,
                                        itemSaleRate: itemData.itemSaleRate,
                                      );
                                      showItemEditPopUp(context, i);
                                    },
                                    icon: Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      deleteItem(itemData.itemId);
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemCount: newItemList.length,
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: FloatingActionButton(
                  onPressed: () {
                    showItemCategoryPopUp(context);
                  },
                  tooltip: 'Add Category',
                  child: Icon(Icons.category, color: Colors.pink),
                ),
              ),
              Spacer(),
              FloatingActionButton(
                onPressed: () {
                  showItemPopUp(context);
                },
                tooltip: 'Add Item',
                child: Icon(Icons.shopping_cart_checkout, color: Colors.indigo),
              ),
            ],
          ),
        );
      }
    );
  }

  String getItemCategory(String itemCatId) {
    String itemCategoryName = '';
    for (var doc in itemCategoryNotifier.value) {
      if (doc.itemCategoryID == itemCatId) {
        itemCategoryName = doc.itemCategoryName;
      }
    }
    return itemCategoryName;
  }

  void showItemCategoryPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Item Category'),
          content: SizedBox(
            height: 100,
            child: Form(
              key: _formItemCategory,
              child: Column(
                children: [
                  TextFormField(
                    controller: itemCategoryController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Category required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Category Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formItemCategory.currentState!.validate()) {
                  itemCategoryId = itemCategoryId + 1;
                  ItemCategoryModel c = ItemCategoryModel(
                    itemCategoryID: itemCategoryId.toString(),
                    itemCategoryName: itemCategoryController.text,
                  );
                  addItemCategory(c);
                  itemCategoryController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void showItemPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Item '),
          content: SizedBox(
            height: 350,
            child: Form(
              key: _formItem,
              child: Column(
                children: [
                  TextFormField(
                    controller: itemNameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Item required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Item Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField(
                    hint: Text('Select an Item Category'),
                    validator: (value) {
                      if (value == null) {
                        return 'Category required';
                      }
                      return null;
                    },
                    items:
                        itemCategoryNotifier.value.map((category) {
                          return DropdownMenuItem(
                            value: category.itemCategoryID,
                            child: Text(category.itemCategoryName),
                          );
                        }).toList(),
                    value: selectedItemCategory,
                    onChanged: (newItemCategory) {
                      selectedItemCategory = newItemCategory;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: itemMrpController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'MRP required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Item MRP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: itemSaleRateController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Sale Rate required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Item Sale Rate',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formItem.currentState!.validate()) {
                  itemId = itemId + 1;
                  ItemModel i = ItemModel(
                    itemId: itemId.toString(),
                    itemCategoryID: selectedItemCategory!,
                    itemName: itemNameController.text,
                    itemMrp: itemMrpController.text,
                    itemSaleRate: itemSaleRateController.text,
                  );
                  addItem(i);
                  itemNameController.clear();
                  itemMrpController.clear();
                  itemSaleRateController.clear();
                  selectedItemCategory = null;
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void showItemEditPopUp(BuildContext context, ItemModel item) {
    itemNameController.text = item.itemName;
    selectedItemCategory = item.itemCategoryID;
    itemMrpController.text = item.itemMrp;
    itemSaleRateController.text = item.itemSaleRate;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Item '),
          content: SizedBox(
            height: 350,
            child: Form(
              key: _formItem,
              child: Column(
                children: [
                  TextFormField(
                    controller: itemNameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Item required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Item Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField(
                    hint: Text('Select an Item Category'),
                    validator: (value) {
                      if (value == null) {
                        return 'Category required';
                      }
                      return null;
                    },
                    items:
                        itemCategoryNotifier.value.map((category) {
                          return DropdownMenuItem(
                            value: category.itemCategoryID,
                            child: Text(category.itemCategoryName),
                          );
                        }).toList(),
                    value: selectedItemCategory,
                    onChanged: (newItemCategory) {
                      selectedItemCategory = newItemCategory;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: itemMrpController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'MRP required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Item MRP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: itemSaleRateController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Sale Rate required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Item Sale Rate',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formItem.currentState!.validate()) {
                  ItemModel i = ItemModel(
                    itemId: item.itemId,
                    itemCategoryID: selectedItemCategory!,
                    itemName: itemNameController.text,
                    itemMrp: itemMrpController.text,
                    itemSaleRate: itemSaleRateController.text,
                  );
                  editItem(i);
                  itemNameController.clear();
                  itemMrpController.clear();
                  itemSaleRateController.clear();
                  selectedItemCategory = null;
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
