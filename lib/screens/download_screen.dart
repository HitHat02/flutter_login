import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


// Download Page
class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  List<dynamic> _files = [];
  final String baseUrl = "http://13.211.150.198:8000";
  final Dio _dio = Dio();

  void _fetchFiles() async {
    try {
      Response response = await _dio.get('$baseUrl/files');

      if (response.statusCode == 200) {
        setState(() {
          _files = response.data;
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
                final downloadUrl = '$baseUrl/download/${_files[index]['id']}';

                try {
                  Response response = await _dio.get(
                    downloadUrl,
                    options: Options(responseType: ResponseType.bytes),
                  );

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