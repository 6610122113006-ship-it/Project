import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. เพิ่มตัวนี้เพื่อใช้ FilteringTextInputFormatter
import 'package:hive/hive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _phone = TextEditingController();

  void _handleLogin() {
    String username = _user.text.trim();
    String password = _pass.text.trim();
    String phoneNumber = _phone.text.trim();

    if (username.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
      _showError('กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return;
    }

    if (password == phoneNumber) {
      _showError('รหัสผ่านและเบอร์โทรศัพท์\nต้องไม่เป็นค่าเดียวกัน');
      return;
    }

    // 2. แก้ไขเงื่อนไขตรงนี้ให้เช็คว่าต้องเท่ากับ 10 หลักพอดี
    if (phoneNumber.length != 10) {
      _showError('กรุณากรอกเบอร์โทรศัพท์ให้ครบ 10 หลัก');
      return;
    }

    Hive.box('auth_box').put('isLoggedIn', true);
    Hive.box('auth_box').put('currentUser', username);
    Hive.box('auth_box').put('userPhone', phoneNumber);

    Navigator.pushReplacementNamed(context, '/');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Kanit')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.orangeAccent],
            begin: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pets, size: 80, color: Colors.orange),
                    const Text('เข้าสู่ระบบ Village Pet Watch',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _user,
                      decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้', prefixIcon: Icon(Icons.person))
                    ),
                    TextField(
                      controller: _pass,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'รหัสผ่าน', prefixIcon: Icon(Icons.lock))
                    ),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      // 3. เพิ่มบรรทัดนี้เพื่อบังคับให้พิมพ์ได้เฉพาะตัวเลขเท่านั้น
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                      decoration: const InputDecoration(
                        labelText: 'เบอร์โทรศัพท์',
                        prefixIcon: Icon(Icons.phone),
                        counterText: "", 
                      )
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: _handleLogin,
                      child: const Text('เข้าใช้งาน', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}