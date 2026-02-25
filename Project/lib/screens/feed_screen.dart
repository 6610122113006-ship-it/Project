import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // สำคัญ: ต้องนำเข้าเพื่อใช้ base64Decode

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) {
    var authBox = Hive.box('auth_box');
    authBox.put('isLoggedIn', false);
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _deletePost(BuildContext context, Box box, int originalIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 10),
            Text('ยืนยันการลบ'),
          ],
        ),
        content: const Text('คุณยืนยันว่าเจอสัตว์เลี้ยงแล้ว และต้องการลบโพสต์นี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              box.deleteAt(originalIndex);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ลบประกาศสำเร็จ'), backgroundColor: Colors.redAccent),
              );
            },
            child: const Text('ยืนยันลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ช่วยเหลือสัตว์หาย', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          )
        ],
      ),
      backgroundColor: const Color(0xFFFFF3E0),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('pet_box').listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) return const Center(child: Text('ยังไม่มีการแจ้งเรื่องในขณะนี้'));

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final int originalIndex = box.length - 1 - index;
              final pet = box.getAt(originalIndex);
              
              // ดึงข้อมูลรูป (ซึ่งตอนนี้เป็น Base64 String)
              final String? imageData = pet['image'] ?? pet['imageUrl'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // --- ส่วนแสดงรูปภาพที่แก้ไขใหม่ ---
                        _buildImageWidget(imageData),
                        
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _deletePost(context, box, originalIndex),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.delete_outline, color: Colors.white, size: 18),
                                  SizedBox(width: 4),
                                  Text('ลบประกาศนี้', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${pet['name']} (${pet['type']})',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.orange.shade900),
                                ),
                              ),
                              if (pet['reward'] != null && pet['reward'] != '0' && pet['reward'].toString().isNotEmpty)
                                _buildRewardBadge(pet['reward'].toString()),
                            ],
                          ),
                          const Divider(),
                          _buildDetailRow(Icons.pets, 'สายพันธุ์: ${pet['breed'] ?? '-'}'),
                          _buildDetailRow(Icons.transgender, 'เพศ: ${pet['gender'] ?? 'ไม่ระบุ'}'),
                          _buildDetailRow(Icons.location_on, 'สถานที่หาย: ${pet['location'] ?? 'ไม่ระบุ'}'),
                          const SizedBox(height: 10),
                          const Text('รายละเอียดเพิ่มเติม:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${pet['detail'] ?? '-'}', style: const TextStyle(color: Colors.black87)),
                          const SizedBox(height: 20),
                          _buildCallButton(pet['phone']?.toString() ?? ''),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create'),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ฟังก์ชันช่วยเลือกว่าจะแสดงรูปจาก Network หรือ Base64
  Widget _buildImageWidget(String? data) {
    if (data == null || data.isEmpty) {
      return _buildPlaceholder();
    }

    // ถ้าข้อมูลขึ้นต้นด้วย http ให้โหลดจากเน็ต
    if (data.startsWith('http')) {
      return Image.network(
        data,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } 
    
    // ถ้าไม่ใช่ http ให้ถือว่าเป็น Base64 (รูปที่เลือกจากเครื่อง)
    try {
      return Image.memory(
        base64Decode(data),
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } catch (e) {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text('ไม่พบรูปภาพ', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRewardBadge(String reward) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
      child: Text('รางวัล: $reward ฿', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCallButton(String phone) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: phone.isNotEmpty ? () => launchUrl(Uri.parse('tel:$phone')) : null,
        icon: const Icon(Icons.phone),
        label: Text('โทรหาเจ้าของ: $phone'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.orange.shade700),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(fontSize: 15, color: Colors.grey[800]))),
      ]),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          TextButton(onPressed: () { Navigator.pop(context); _logout(context); }, child: const Text('ตกลง', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}