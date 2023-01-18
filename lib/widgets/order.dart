
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quanlytaphoa_mobile/model/order_item.dart';
import 'package:quanlytaphoa_mobile/repository/depot_repository.dart';
import 'package:quanlytaphoa_mobile/widgets/item_detail.dart';
import 'package:quanlytaphoa_mobile/widgets/qr_scanner.dart';

import '../model/item.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  final ScrollController _controller = ScrollController();
  bool isAddingNewItem = false;
  List<OrderItem> _orderItemList = [];
  final DepotRepository _depotRepository = DepotRepository();

  @override
  void initState() {
    isAddingNewItem = false;
    _depotRepository.connect("192.168.31.148");
    super.initState();
  }

  @override
  void dispose() async {
    await _depotRepository.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("ĐƠN HÀNG"),
          trailing: GestureDetector(
            child: Icon(CupertinoIcons.add),
            onTap: () async {
              await _add_new_item();
            },
          ),
        ),
        child: Column(children: <Widget>[
          Expanded(
            child: SafeArea(
              child: ListView.builder(
                controller: _controller,
                padding: EdgeInsets.only(bottom: 10),
                itemCount: _orderItemList.length,
                itemBuilder: (context, index) {
                  final item = _orderItemList[index];
                  return Card(
                      elevation: 6,
                      //margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: ListTile(
                        minLeadingWidth: 20,
                        horizontalTitleGap: 0,
                        leading: Text(
                          (index + 1).toString(),
                        ),
                        title: Text(item.name),
                        subtitle: Text(item.price.toString() +
                            " \n x " +
                            item.quantity.toString() +
                            " " +
                            item.dvt),
                        trailing: Wrap(
                          //pace between two icons
                          children: <Widget>[
                            Text(item.getTotalPrice().toString()), // icon-1
                            CupertinoButton(
                              child: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _orderItemList.removeAt(index);
                                });
                              },
                            ), // icon-2
                          ],
                        ),
                        onTap: () async {
                          //   await showUserDetail(index);
                          int result = await showSelectedOrderItemDialog(item);
                          if (result > 0) {
                            setState(() {
                              _orderItemList[index].quantity = result;
                            });
                          } else if (result == -1) {
                            //sửa gia
                            Item updatedItem = await Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) =>
                                    ItemDetailWidget(item: item.baseItem),
                              ),
                            );
                            setState(() {
                              OrderItem newOrderItem = OrderItem(updatedItem);
                              newOrderItem.quantity = item.quantity;
                              _orderItemList[index] = newOrderItem;
                            });
                          } else if (result == -2) {
                            //them hang cung ma
                            Item newItem = Item();
                            String barcode = item.id.split("_")[0];
                            newItem.id = barcode +
                                "_" +
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                            Item editedItem = await Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) =>
                                    ItemDetailWidget(item: newItem),
                              ),
                            );
                            _depotRepository.insertItem(editedItem);
                            insertItemToBill(editedItem);
                          }
                        },
                      ));
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              //alignment: WrapAlignment.spaceAround,
              children: [
                const Text("10000000", style: TextStyle(fontSize: 30)),
                Spacer(),
                TextButton(onPressed: () {}, child: Text("Thanh toan"))
              ],
            ),
          )
        ]));
  }

  _add_new_item() async {
    var barcode = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const QRScanner(),
      ),
    );
    if(barcode== null) {
      return;
    }
    print("found barcode: " + barcode);
    //kiem tra xem item co ton tai chua
    List<Item> items = await _depotRepository.getItems(barcode);
    if (items.isEmpty) {
      //tao item moi
      Item item = Item();
      item.id = barcode;
      var newItem = await Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => ItemDetailWidget(item: item),
        ),
      );
      if (newItem != null) {
        await _depotRepository.insertItem(newItem);
        insertItemToBill(newItem);
      }
    } else {
      if (items.length == 1) {
        //chi co 1 mat hang
        insertItemToBill(items[0]);
      } else {
        Item selectedItem = await showMultiItemSelectDialog(items);
        insertItemToBill(selectedItem);
      }
    }
  }

  insertItemToBill(Item item) {
    setState(() {
      print("insert item to bill: " + item.name + " " + item.dvt);
      OrderItem orderItem = OrderItem(item);
      for (OrderItem oi in _orderItemList) {
        if (oi.id == orderItem.id) {
          _orderItemList.remove(oi);
          oi.quantity = oi.quantity + 1;
          _orderItemList.add(oi);
          return;
        }
      }
      _orderItemList.add(orderItem);
    });
  }

  Future showSelectedOrderItemDialog(OrderItem orderItem) async {
    return await showCupertinoDialog(
        context: context,
        builder: (context) {
          int _quantity = orderItem.quantity;
          return StatefulBuilder(builder: (context, setState) {
            return CupertinoAlertDialog(
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      CupertinoButton(
                          onPressed: () {
                            if (_quantity > 1) {
                              setState(() {
                                _quantity--;
                              });
                            }
                          },
                          child: const Icon(Icons.arrow_back)),
                      Expanded(
                          child: Text(
                        _quantity.toString(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                      CupertinoButton(
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                          child: const Icon(Icons.arrow_forward)),
                    ],
                  ),
                  CupertinoButton(
                      onPressed: () {
                        Navigator.of(context).pop(-1);
                      },
                      child: const Text("Sửa giá")),
                  CupertinoButton(
                      onPressed: () {
                        Navigator.of(context).pop(-2);
                      },
                      child: const Text("Thêm hàng cùng mã")),
                ],
              ),
              title: Text(orderItem.name),
              actions: [
                // Close the dialog
                // You can use the CupertinoDialogAction widget instead
                CupertinoButton(
                    child: Text('Hủy bỏ'),
                    onPressed: () {
                      Navigator.of(context).pop(0);
                    }),
                CupertinoButton(
                  child: Text('Lưu'),
                  onPressed: () {
                    // Then close the dialog
                    Navigator.of(context).pop(_quantity);
                  },
                )
              ],
            );
          });
        });
  }

  Future showMultiItemSelectDialog(List<Item> items) async {
    return await showCupertinoDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return CupertinoAlertDialog(
              content: Column(
                children: <Widget>[
                  ...items.map((item) {
                    return TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(item);
                      },
                      child: Text(item.name + " - " + item.dvt),
                    );
                  }).toList(),
                ],
              ),
              title: Text("Chọn hàng"),
              actions: [
                // Close the dialog
                // You can use the CupertinoDialogAction widget instead
                CupertinoButton(
                    child: Text('Hủy bỏ'),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    }),
              ],
            );
          });
        });
  }
}
