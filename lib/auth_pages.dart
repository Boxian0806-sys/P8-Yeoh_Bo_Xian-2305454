import 'package:flutter/material.dart';
import 'database.dart';
import 'vault_screen.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool isLogin = true;

  // Theme Colors
  final Color bgColor = const Color(0xFF14141E);
  final Color accentColor = const Color(0xFF6F61E8);

  void _submit() async {
    String user = _userController.text;
    String pass = _passController.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      if (isLogin) {
        var result = await DatabaseHelper.instance.loginUser(user, pass);
        
        // This checks if the screen is still active (prevents double-tap crashes)
        if (!mounted) return; 

        if (result != null) {
          int loggedInUserId = result['id']; 
          String loggedInUsername = result['username']; 
          
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Login successful!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2), 
          ));

          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (context) => VaultScreen(userId: loggedInUserId, username: loggedInUsername)
            )
          );
          return; 
        } else {
          // This will ONLY run if result is actually null
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Login invalid, please try again."), 
            backgroundColor: Colors.redAccent
          ));
        }
      } else {
        // 1. Capture the result of the registration attempt
        int result = await DatabaseHelper.instance.registerUser(user, pass);
        if (!mounted) return;

        // 2. Check if the database returned our -1 error code
        if (result == -1) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Username used, please try another username"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ));
          return; // Stop here! Do not create the account or switch screens.
        }

        // 3. If it wasn't -1, the account was created successfully!
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Account created! Please login."),
          backgroundColor: Colors.green
        ));
        setState(() => isLogin = true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("System Error: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('asset/icon.png', height: 80),
              SizedBox(height: 20),
              Text(
                isLogin ? "Welcome Back" : "Create Account", 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)
              ),
              SizedBox(height: 30),
              TextField(
                controller: _userController, 
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor, width: 2), borderRadius: BorderRadius.circular(12)),
                )
              ),
              SizedBox(height: 15),
              TextField(
                controller: _passController, 
                style: TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.key_outlined, color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor, width: 2), borderRadius: BorderRadius.circular(12)),
                )
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: _submit, 
                child: Text(isLogin ? "Login" : "Sign Up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin ? "No account? Sign up here" : "Have an account? Login",
                  style: TextStyle(color: accentColor, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}