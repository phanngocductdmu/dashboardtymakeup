import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  final String title;
  final ValueChanged<String>? onSearchChanged;
  final Future<void> Function(BuildContext) onLogout;

  const Header({
    required this.title,
    required this.onLogout,
    this.onSearchChanged,
    super.key,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus && _searchController.text.isEmpty) {
        setState(() {
          _isSearchExpanded = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.black, // nền header đen
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // chữ trắng
            ),
          ),
          const Spacer(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSearchExpanded ? 265 : 45,
            child: _isSearchExpanded
                ? TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search,
                    color: Colors.white70, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 15),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: widget.onSearchChanged,
            )
                : Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white70),
                onPressed: () {
                  setState(() {
                    _isSearchExpanded = true;
                    _searchFocus.requestFocus();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
