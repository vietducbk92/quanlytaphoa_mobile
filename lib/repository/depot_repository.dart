
import 'package:mongo_dart/mongo_dart.dart';
import 'package:quanlytaphoa_mobile/model/item.dart';

class DepotRepository {
  late Db db;
  connect(String serverIp) async {
    db = Db("mongodb://$serverIp:27017/SellManagerDB");
    await db.open();

  }
  disconnect() async{
    if(db.isConnected){
      await db.close();
    }
  }
  insertItem(Item item) async{
    var collection = db.collection("depot");
    await collection.insert({
      "_id": item.id,
      "_name": item.name,
      "_oiigin_price":item.price,
      "_category":"",
      "_note":"",
      "_rt_max_number":item.wsNumber,
      "_rt_price": item.price,
      "_ws_price":item.wsPrice,
      "_unit": item.dvt,
      "_has_barcode":true,
    });
  }
  getItems(String barcode) async{
    List<Item> items = [];
    var collection = db.collection("depot");
    await collection.find({"_id": {'\$regex': '${barcode}'}}).forEach((i) {
      Item item = Item();
      if(i.containsKey("_id"))
        item.id = i["_id"];
      if(i.containsKey("_name"))
       item.name = i["_name"];
      if(i.containsKey("_rt_price"))
        item.price = i["_rt_price"];
      if(i.containsKey("_unit"))
        item.dvt = i["_unit"];
      if(i.containsKey("ws_price"))
        item.wsPrice = i["ws_price"];
      if(i.containsKey("_rt_max_number"))
        item.wsNumber = i["_rt_max_number"];
      items.add(item);
    });
    return items;
  }

}