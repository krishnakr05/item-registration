class ItemModel {
  String itemId;
  String itemCategoryID;
  String itemName;
  String itemMrp;
  String itemSaleRate;

  ItemModel({
    required this.itemId,
    required this.itemCategoryID,
    required this.itemName,
    required this.itemMrp,
    required this.itemSaleRate,
  });
}
/*
factory ItemModel.fromMap(Map<String, dynamic> map, String docId){

}
*/
