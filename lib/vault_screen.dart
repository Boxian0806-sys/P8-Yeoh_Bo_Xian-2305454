import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:async'; 
import 'database.dart';
import 'auth_screen.dart';

class VaultScreen extends StatefulWidget {
  final int userId;
  final String username;

  VaultScreen({required this.userId, required this.username});

  @override
  _VaultScreenState createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  List<Map<String, dynamic>> _passwords = [];
  bool _isLoading = true;
  Set<int> _visiblePasswords = {};

  final TextEditingController _siteController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final Color bgColor = const Color(0xFF14141E);
  final Color cardColor = const Color(0xFF1E1E2E);
  final Color accentColor = const Color(0xFF6F61E8);

  @override
  void initState() {
    super.initState();
    _preloadAndRefresh();
  }

  //dummy password vault to demonstrate the function 
  Future<void> _preloadAndRefresh() async {
    final data = await DatabaseHelper.instance.queryUserPasswords(widget.userId);
    if (data.isEmpty) {
      final dummyData = [
        {'userId': widget.userId, 'siteName': 'WBLE UTAR', 'username': '2305454', 'password': 'UtarPassword1'},
      ];
      for (var entry in dummyData) {
        await DatabaseHelper.instance.addEntry(entry);
      }
    }
    _refreshPasswords();
  }

  void _refreshPasswords() async {
    final data = await DatabaseHelper.instance.queryUserPasswords(widget.userId);
    setState(() {
      _passwords = data;
      _isLoading = false;
    });
  }

  // the copy feature
  void _copyToClipboard(String password) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Password copied! Clears in 30 seconds.'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ));
  
    Timer(Duration(seconds: 30), () {
      Clipboard.setData(ClipboardData(text: '')); 
    });
  }

  void _deleteEntry(int id) async {
    await DatabaseHelper.instance.deleteEntry(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password removed successfully')));
    _refreshPasswords();
  }

  Future<void> _addEntry() async {
    await DatabaseHelper.instance.addEntry({
      'userId': widget.userId,
      'siteName': _siteController.text,
      'username': _userController.text,
      'password': _passController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password added successfully')));
    _refreshPasswords();
  }

  Future<void> _updateEntry(int id) async {
    await DatabaseHelper.instance.updateEntry({
      'id': id,
      'userId': widget.userId,
      'siteName': _siteController.text,
      'username': _userController.text,
      'password': _passController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully')));
    _refreshPasswords();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingData = _passwords.firstWhere((element) => element['id'] == id);
      _siteController.text = existingData['siteName'];
      _userController.text = existingData['username'];
      _passController.text = existingData['password'];
    } else {
      _siteController.text = '';
      _userController.text = '';
      _passController.text = '';
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      backgroundColor: cardColor, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 20, left: 20, right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(id == null ? 'New Password Vault' : 'Edit Password Vault', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: _siteController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Website / App Name', labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.web, color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _userController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Username / Email', labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.person, color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _passController,
              style: TextStyle(color: Colors.white),
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password', labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.password, color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: () async {
                if (id == null) {
                  await _addEntry();
                } else {
                  await _updateEntry(id);
                }
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Save' : 'Update', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: accentColor),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Welcome Back, ${widget.username}!', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthPage()));
            },
          ),
        ],
      ),
      
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _passwords.length,
              itemBuilder: (context, index) {
                final entry = _passwords[index];
                return Card(
                  color: cardColor, 
                  elevation: 0, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white12, width: 1) 
                  ),
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: bgColor,
                      child: Icon(Icons.language, color: accentColor),
                    ),
                    title: Text(entry['siteName'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry['username'], style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 4),
                          Text(
                            _visiblePasswords.contains(entry['id']) ? entry['password'] : '••••••••',
                            style: TextStyle(
                              color: _visiblePasswords.contains(entry['id']) ? Colors.white : accentColor,
                              letterSpacing: _visiblePasswords.contains(entry['id']) ? 0 : 3,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The sleek new Copy Button
                        IconButton(
                          icon: Icon(Icons.copy, color: Colors.white54, size: 20),
                          onPressed: () => _copyToClipboard(entry['password']),
                        ),
                        IconButton(
                          icon: Icon(
                            _visiblePasswords.contains(entry['id']) ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white54,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_visiblePasswords.contains(entry['id'])) {
                                _visiblePasswords.remove(entry['id']);
                              } else {
                                _visiblePasswords.add(entry['id']);
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteEntry(entry['id']),
                        ),
                      ],
                    ),
                    onTap: () => _showForm(entry['id']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        child: Icon(Icons.add, size: 28),
        onPressed: () => _showForm(null), 
      ),
    );
  }
}