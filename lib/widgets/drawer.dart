import 'package:flutter/material.dart';
import 'package:map_tanks/constants.dart';

class AppDrawer extends StatelessWidget {
  final int? selectedIndex;
  final Function(int) onItemTapped;
  const AppDrawer({super.key, this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.grey.shade900,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.green,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 15,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(Constants.profilePictureAsset),
                  ),
                  Text(
                    "Войти в приложение",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Меню", style: TextStyle(color: Colors.white)),
                  ),
                  ListView.builder(
                    itemCount: drawerItems.length,
                    itemBuilder: (context, index) {
                      final item = drawerItems[index];
                      return ListTile(
                        contentPadding: EdgeInsets.all(4),
                        tileColor:
                            selectedIndex == index
                                ? Colors.grey.shade700
                                : null,
                        leading: Icon(
                          item.$1,
                          color:
                              selectedIndex == index
                                  ? Colors.green
                                  : Colors.white,
                        ),
                        title: Text(
                          item.$2,
                          style: TextStyle(
                            color:
                                selectedIndex == index
                                    ? Colors.green
                                    : Colors.white,
                          ),
                        ),
                        onTap: () {
                          onItemTapped(index);
                          Navigator.pop(context);
                        },
                      );
                    },
                    shrinkWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<(IconData, String)> drawerItems = [
  (Icons.add, "Мой профиль"),
  (Icons.edit, "Мои танки"),
  (Icons.arrow_back, "Кто рядом"),
  (Icons.check, "Настройки"),
];
