import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final Function(String) onSelect;
  const Sidebar({required this.onSelect, Key? key}) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    Widget buildMenuItem(IconData icon, String title) {
      return ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        hoverColor: Colors.grey[800],
        onTap: () => widget.onSelect(title),
      );
    }

    return Container(
      width: 240,
      color: Colors.black,
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 7),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Admin Panel\n',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Welcome, Admin',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          buildMenuItem(Icons.post_add, 'Posts'),
          buildMenuItem(Icons.image_outlined, 'Post'),
          buildMenuItem(Icons.logout, 'Logout'),
        ],
      ),
    );
  }
}
