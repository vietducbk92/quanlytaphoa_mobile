import 'package:quanlytaphoa_mobile/model/item.dart';

class OrderItem{
  late Item baseItem;
  String id = "";
  String name = "";
  String dvt = "";
  int quantity = 1;
  double price = 0;
  double getTotalPrice(){
    return price*quantity;
  }
  OrderItem(Item item){
    baseItem = item;
    id = item.id;
    name = item.name;
    dvt = item.dvt;
    price = item.price;
  }
}