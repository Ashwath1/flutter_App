import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Tensorflow extends StatefulWidget {
  @override
  _TensorflowState createState() => _TensorflowState();
}

class _TensorflowState extends State<Tensorflow> {
  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
  }

  // Future<Widget> createDialog(BuildContext context, String s) {
  //   return showDialog(
  //       context: context,
  //       builder: (_) => new AlertDialog(
  //             title: new Text("Your results are here!"),
  //             content: new Text('$s'),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: Text(
  //                   'Ok',
  //                   style: TextStyle(
  //                     fontSize: 18.0,
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.pushNamed(context, '/SignIn');
  //                 },
  //               ),
  //             ],
  //           ));
  // }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Predicting the Infection",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _loading
                ? Container(
                    height: 300,
                    width: 300,
                  )
                : Container(
                    margin: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _image == null ? Container() : Image.file(_image),
                        SizedBox(
                          height: 20,
                        ),
                        _image == null
                            ? Container()
                            : _outputs != null
                                ? Text(
                                    _outputs[0]["label"],
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20),
                                  )
                                // ? createDialog(context, _outputs[0]["label"])
                                : Container(child: Text(""))
                      ],
                    ),
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            FloatingActionButton(
              tooltip: 'Pick Image',
              onPressed: pickImage,
              child: Icon(
                Icons.add_a_photo,
                size: 20,
                color: Colors.white,
              ),
              backgroundColor: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
}
