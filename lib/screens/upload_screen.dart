import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

// Upload Page
class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<PlatformFile> _selectedFiles = [];
  final String baseUrl = "http://13.211.150.198:8000";
  final Dio _dio = Dio();

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  Future<void> _uploadFiles() async {
    try {
      FormData formData = FormData();

      for (var file in _selectedFiles) {
        formData.files.add(
          MapEntry(
            'files',
            MultipartFile.fromBytes(
              file.bytes!,
              filename: file.name,
              contentType: MediaType('application', 'octet-stream'),
            ),
          ),
        );
      }

      Response response = await _dio.post(
        '$baseUrl/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Files uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload files.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Files'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickFiles,
            child: Text('Pick Files'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_selectedFiles[index].name),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _uploadFiles,
            child: Text('Upload Files'),
          ),
        ],
      ),
    );
  }
}