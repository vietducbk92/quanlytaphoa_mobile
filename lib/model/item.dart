class Item{
  String id = "";
  String name = "";
  double price = 0;
  String dvt = "";
  double wsPrice = 0;
  int wsNumber = 0;

  static Item from(Item otherItem){
    Item out = Item();
    out.id = otherItem.id;
    out.name = otherItem.name;
    out.price = otherItem.price;
    out.dvt = otherItem.dvt;
    out.wsPrice = otherItem.wsPrice;
    out.wsNumber = otherItem.wsNumber;
    return out;
  }
}