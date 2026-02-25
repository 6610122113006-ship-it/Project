import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // เพิ่มสำหรับ TextInputFormatter
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:typed_data'; 
import 'dart:convert'; 

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _loc = TextEditingController();
  final _phone = TextEditingController();
  final _detail = TextEditingController();
  final _reward = TextEditingController();
  
  String _type = 'แมว';
  String _gender = 'ไม่ระบุ';
  
  Uint8List? _webImage; 
  String? _base64String; 
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600, // ลดขนาดลงอีกนิดเพื่อให้ Hive ทำงานลื่นขึ้น
      imageQuality: 50,
    );
    
    if (image != null) {
      var f = await image.readAsBytes();
      setState(() {
        _webImage = f;
        _base64String = base64Encode(f); 
      });
    }
  }

  void _savePost() {
    if (_name.text.isEmpty || _loc.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลที่จำเป็นให้ครบ (ชื่อ, สถานที่, เบอร์โทร)')),
      );
      return;
    }

    Hive.box('pet_box').add({
      'name': _name.text,
      'type': _type,
      'gender': _gender,
      'breed': _breed.text,
      'location': _loc.text,
      'phone': _phone.text,
      // บันทึกโดยใช้คีย์ 'image' เพื่อให้ตรงกับการเรียกใช้ในหน้า Feed
      'image': _base64String ?? '', 
      'reward': _reward.text.isEmpty ? '0' : _reward.text,
      'detail': _detail.text,
      'timestamp': DateTime.now().toString(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แจ้งเรื่องสัตว์หาย', style: TextStyle(fontFamily: 'Kanit')),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 2),
                ),
                child: _webImage != null 
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.memory(_webImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo, size: 60, color: Colors.orange),
                        SizedBox(height: 10),
                        Text('คลิกเพื่อเลือกรูปภาพจากเครื่อง', 
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
              ),
            ),

            Row(
              children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'ประเภทสัตว์', border: OutlineInputBorder()),
                  items: ['แมว', 'หมา', 'นก', 'กระต่าย', 'หนู', 'เต่า', 'อื่นๆ']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                )),
                const SizedBox(width: 10),
                Expanded(child: DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'เพศ', border: OutlineInputBorder()),
                  items: ['ไม่ระบุ', 'ผู้', 'เมีย']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _gender = v!),
                )),
              ],
            ),
            const SizedBox(height: 15),
            _buildField(_name, 'ชื่อสัตว์เลี้ยง *', Icons.badge),
            // แก้ไข: สายพันธุ์ห้ามใส่ตัวเลข
            _buildField(_breed, 'สายพันธุ์', Icons.pets, noNumber: true),
            _buildField(_loc, 'สถานที่หาย *', Icons.location_on),
            // แก้ไข: เบอร์โทรใส่ได้เฉพาะตัวเลข
            _buildField(_phone, 'เบอร์โทรติดต่อเจ้าของ *', Icons.phone, isNumber: true),
            // แก้ไข: รางวัลใส่ได้เฉพาะตัวเลข
            _buildField(_reward, 'จำนวนเงินรางวัล (บาท)', Icons.money, isNumber: true),
            
            const SizedBox(height: 5),
            TextField(
              controller: _detail,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'กรอกรายละเอียดเพิ่มเติม',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _savePost,
              child: const Text('ยืนยันลงประกาศ', 
                style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Kanit', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String l, IconData i, {bool isNumber = false, bool noNumber = false}) {
    List<TextInputFormatter> formatters = [];
    
    // ใส่ได้เฉพาะตัวเลข
    if (isNumber) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    
    // ห้ามใส่ตัวเลข
    if (noNumber) {
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'[0-9]')));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: formatters,
        decoration: InputDecoration(
          labelText: l,
          prefixIcon: Icon(i),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}