import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String user = Hive.box('auth_box').get('currentUser', defaultValue: 'Admin');
    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังรูปสัตว์เลี้ยง
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1548191265-cc70d3d45ba1?q=80&w=1000'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)), // แผ่นกรองสีเพื่อให้ตัวหนังสือเด่น
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pets, size: 100, color: Colors.orangeAccent),
                const SizedBox(height: 20),
                Text('ยินดีต้อนรับ\nคุณ $user',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/feed'),
                  child: const Text('ดูรายการสัตว์หาย', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}