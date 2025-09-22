import 'package:flutter/material.dart';
import '/components/sidebar.dart';
import '/components/header.dart';
import '/pages/post_page.dart';
import '/pages/posts_page.dart';
import '../pages/login_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedMenu = 'Posts';
  String? avatarUrl;
  String searchQuery = '';
  bool _isSearchExpanded = false;
  late bool isPortrait;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginPage()),
            (Route<dynamic> route) => false,
      );
    }
  }


  Widget getContent() {
    switch (selectedMenu) {
      case 'Posts':
        return PostsPage();
      case 'Post':
        return PostPage();
      default:
        return PostsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    isPortrait = size.height > size.width;

    if (isPortrait) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Row(
            children: [
              // Nếu chưa mở rộng, hiển thị tên menu
              if (!_isSearchExpanded)
                Text(
                  selectedMenu,
                  style: const TextStyle(color: Colors.white),
                ),
              // Dùng Expanded cho TextField để không overflow
              if (_isSearchExpanded)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      cursorColor: Colors.grey,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      autofocus: true,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  if (_isSearchExpanded) searchQuery = '';
                  _isSearchExpanded = !_isSearchExpanded;
                });
              },
            ),
          ],
        ),

        drawer: Drawer(
          width: MediaQuery.of(context).size.height * 0.3,
          child: Sidebar(
            onSelect: (menu) {
              setState(() {
                selectedMenu = menu;
              });
              Navigator.pop(context);
            },
          ),
        ),
        body: getContent(),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            Sidebar(
              onSelect: (menu) {
                if (menu == 'Logout') {
                  _confirmLogout(context);
                } else {
                  setState(() {
                    selectedMenu = menu;
                  });
                }
              },
            ),

            Expanded(
              child: Column(
                children: [
                  Header(
                    title: selectedMenu,
                    onSearchChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    onLogout: _confirmLogout,
                  ),
                  Expanded(child: getContent()),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
