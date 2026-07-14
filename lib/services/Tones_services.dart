import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';

class Tones extends StatefulWidget {
  const Tones({Key? key}) : super(key: key);

  @override
  State<Tones> createState() => _TonesState();
}

class _TonesState extends State<Tones> {
  // 🎵 دالة اختيار ملف الصوت بنجاح
  Future<String?> pickToneFile() async {
    try {
      // ✅ السنتَكس الصحيح والمباشر لي خدم ليك
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.single.path;
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Tones Selection'),
      ),
      child: SafeArea(
        child: Center(
          child: Text('صفحة النغمات جاهزة ومصلحة'),
        ),
      ),
    );
  }
}