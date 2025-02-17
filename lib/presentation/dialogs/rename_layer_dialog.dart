 import 'package:flutter/material.dart';

Future<String?> showRenameDialog(BuildContext context, String currentName) async {
    TextEditingController controller = TextEditingController(text: currentName);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Введите новое название слоя'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Введите название'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Сохранить'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }