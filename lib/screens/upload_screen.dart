import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Upload Page
class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<PlatformFile> _selectedFiles = [];
  final String uploadUrl = "http://13.211.150.198:8000";

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
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      for (var file in _selectedFiles) {
        request.files.add(await http.MultipartFile.fromPath('files', file.path!));
      }

      var response = await request.send();

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

// Download Page
class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);
  
  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  List<dynamic> _files = [];
  final String fetchUrl = "http://13.211.150.198:8000";

  void _fetchFiles() async {
    try {
      final response = await http.get(Uri.parse(fetchUrl));

      if (response.statusCode == 200) {
        setState(() {
          _files = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch files.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Files'),
      ),
      body: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_files[index]['name']),
            trailing: IconButton(
              icon: Icon(Icons.download),
              onPressed: () async {
                final downloadUrl = "http://your-fastapi-server/download/${_files[index]['id']}";

                try {
                  final response = await http.get(Uri.parse(downloadUrl));

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('File downloaded successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to download file.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('An error occurred: $e')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
