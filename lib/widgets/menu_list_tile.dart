import 'package:flutter/material.dart';

class MenuListTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final (IconData, String) item;
  const MenuListTile({
    super.key,
    required this.onTap,
    required this.item,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(4),
      tileColor: isSelected ? Colors.grey.shade700 : null,
      leading: Icon(item.$1, color: isSelected ? Colors.green : Colors.white),
      title: Text(
        item.$2,
        style: TextStyle(color: isSelected ? Colors.green : Colors.white),
      ),
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }
}
