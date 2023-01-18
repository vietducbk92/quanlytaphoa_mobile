import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quanlytaphoa_mobile/model/item.dart';

class ItemDetailWidget extends StatefulWidget {
  const ItemDetailWidget({Key? key, required this.item}) : super(key: key);
  final Item item;
  @override
  State<StatefulWidget> createState() => _ItemDetailWidgetState();
}

class _ItemDetailWidgetState extends State<ItemDetailWidget> {
  late Item updateItem ;
  @override
  void initState() {
    updateItem = Item.from(widget.item);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          previousPageTitle: "Hủy",
          middle: const Text("Tài khoản"),
          trailing: GestureDetector(
            onTap: () {
              Navigator.pop(context, updateItem);
            },
            child: const Text("Lưu",style: TextStyle(color: Colors.blueAccent),),
          ),
        ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                CupertinoTextField(
                  prefix: const Text(" Ten:"),
                  padding: const EdgeInsets.all(10.0),
                  keyboardType: TextInputType.text,
                  controller: TextEditingController(text: updateItem.name),
                  onChanged: (text) {
                    updateItem.name = text;
                  },
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  prefix: const Text(" Gia:"),
                  padding: const EdgeInsets.all(10.0),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: updateItem.price==0?"":updateItem.price.toString()),
                  onChanged: (text) {
                    if(text.isNotEmpty) {
                      updateItem.price = double.parse(text);
                    }
                  },
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  prefix: const Text(" Don vi:"),
                  padding: const EdgeInsets.all(10.0),
                  keyboardType: TextInputType.text,
                  controller: TextEditingController(text: updateItem.dvt),
                  onChanged: (text) {
                    updateItem.dvt = text;
                  },
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  prefix: const Text(" So luong si:"),
                  padding: const EdgeInsets.all(10.0),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: updateItem.wsNumber==0?"":updateItem.wsNumber.toString()),
                  onChanged: (text) {
                    if(text.isNotEmpty)
                      updateItem.wsNumber = int.parse(text);
                  },
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  prefix: const Text(" Gia si :"),
                  padding: const EdgeInsets.all(10.0),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: updateItem.wsPrice==0?"":updateItem.wsPrice.toString()),
                  onChanged: (text) {
                    if(text.isNotEmpty)
                      updateItem.wsPrice = double.parse(text);
                  },
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}


