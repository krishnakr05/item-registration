import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:item_registration/Core/core.dart';
import 'package:item_registration/Model/item_category_model.dart';
import 'package:item_registration/Model/item_model.dart';

void addItemCategory(ItemCategoryModel c) async{
  print('Adding category: ${c.itemCategoryName}');
  final firebaseInstance= await FirebaseFirestore.instance
    .collection('category')
    .add({
    'category_name': c.itemCategoryName
  });
  await getAllItems();
  //itemCategoryNotifier.notifyListeners();
}

Future<void> getAllItems() async{
  itemCategoryNotifier.value.clear();
  final documentSnapshot= await FirebaseFirestore.instance.collection('category').get();
  
  for(var doc in documentSnapshot.docs){
    print("Fetched category: ${doc['category_name']}");
    ItemCategoryModel c= ItemCategoryModel(
      itemCategoryID: doc.id,
      itemCategoryName: doc['category_name']
    );
    itemCategoryNotifier.value.add(c);
  }
  itemCategoryNotifier.notifyListeners();
}

void addItem(ItemModel i) async {
  final firebaseInstance= await FirebaseFirestore.instance.collection('items').add({
    'item_id': i.itemId,
    'item_name': i.itemName,
    'item_category_id': i.itemCategoryID,
    'item_mrp': i.itemMrp,
    'item_sale_rate': i.itemSaleRate,
  });
  //getAllItems();
  itemNotifier.value.add(i);
  itemNotifier.notifyListeners();
}

void editItem(ItemModel i) async {
  try {
    final firebaseInstance= await FirebaseFirestore.instance.collection('items').doc(i.itemId).set({
    //'item_id': i.itemId,
    'item_name': i.itemName,
    'item_category_id': i.itemCategoryID,
    'item_mrp': i.itemMrp,
    'item_sale_rate': i.itemSaleRate,
  });

  for (var doc in itemNotifier.value) {
    if (doc.itemId == i.itemId) {
      //doc.itemCategoryID = i.itemCategoryID;
      doc.itemName = i.itemName;
      doc.itemMrp = i.itemMrp;
      doc.itemSaleRate = i.itemSaleRate;
    }
  }
  itemNotifier.notifyListeners();
  } catch (e) {
    print('Error while editing');
  }
}

Future<void> deleteItem(String itemId) async {
  try{
    final snapshot= await FirebaseFirestore.instance
      .collection('items')
      .where('item_id', isEqualTo: itemId)
      .get();
    if(snapshot.docs.isEmpty){
      print("Item not found in Firestore");
      return;
    }
    final docId= snapshot.docs.first.id;
    await FirebaseFirestore.instance.collection('items').doc(docId).delete();
    
    itemNotifier.value.removeWhere((item) => item.itemId == itemId);
    itemNotifier.notifyListeners();
  }catch(e){
    print('Error deleting the file');
  }

  
}
