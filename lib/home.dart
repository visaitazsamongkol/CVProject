import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import './globals.dart' as globals;
import './dict.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool loading = false;
  Image? outputImage;

  void takePicture() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery, //used for test
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (pickedFile != null) {
      sendPicture(File(pickedFile.path));
    }
  }

  void sendPicture(File imageFile) async {
    setState(() => loading = true);
    var url = "https://dictionary-search-ocr-server.herokuapp.com/ocr";
    var req = http.MultipartRequest('POST', Uri.parse(url));
    req.files.add(http.MultipartFile(
        'image', imageFile.readAsBytes().asStream(), imageFile.lengthSync(),
        filename: "flutter_image"));
    var res = await http.Response.fromStream(await req.send());
    if (res.statusCode == 200) {
      var resJson = json.decode(res.body);
      globals.wordList = resJson['words'].cast<String>();
      setState(() {
        outputImage = Image.memory(base64Decode(resJson['base64_string']));
      });
    }
    setState(() => loading = false);
  }

  void goToDictPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Dict()),
    );
  }

  void abortPicture() {
    setState(() {
      outputImage = null;
    });
  }

  // void getPicture() async {
  //   var url = "http://192.168.1.105:5000/image";
  //   var jsonData = await http.get(Uri.parse(url));
  //   var _image = jsonData.bodyBytes;
  //   setState(() {
  //     receivedImage = _image;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home'), centerTitle: true),
      body: loading
          ? globals.startProgressIndicator(context)
          : ListView(
              children: [
                SizedBox(
                  height: 50,
                ),
                outputImage != null
                    ? Container(
                        child: outputImage,
                      )
                    : Icon(
                        Icons.camera_enhance_rounded,
                        color: Colors.green,
                        size: MediaQuery.of(context).size.width * 0.6,
                      ),
                outputImage != null
                    ? Row(children: [
                        Expanded(
                            child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(30.0, 30.0, 10.0, 30.0),
                                child: ElevatedButton(
                                  child: Text('search up!'),
                                  onPressed: () {
                                    goToDictPage();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.green),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(12)),
                                    textStyle: MaterialStateProperty.all(
                                        TextStyle(fontSize: 16)),
                                  ),
                                ))),
                        Expanded(
                            child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(10.0, 30.0, 30.0, 30.0),
                                child: ElevatedButton(
                                  child: Text('retake picture'),
                                  onPressed: () {
                                    abortPicture();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.red),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(12)),
                                    textStyle: MaterialStateProperty.all(
                                        TextStyle(fontSize: 16)),
                                  ),
                                ))),
                      ])
                    : Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: ElevatedButton(
                          child: Text('Take Picture'),
                          onPressed: () {
                            takePicture();
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.purple),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(12)),
                            textStyle: MaterialStateProperty.all(
                                TextStyle(fontSize: 16)),
                          ),
                        )),
              ],
            ),
    );
  }
}
