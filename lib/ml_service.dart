import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:detect_face/localStorage.dart';
import 'package:flutter/material.dart';
// import 'package:face_detection/utils/local_db.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as imglib;
// import '../../../models/user.dart';
// import '../../utils/utils.dart';
import 'image_converter.dart';

class MLService {
  late tfl.Interpreter interpreter;
  List? predictedArray;

  Future<bool> predict(context, CameraImage cameraImage, Face face,
      bool loginUser, String name) async {
    List input = _preProcess(cameraImage, face);
    input = input.reshape([1, 112, 112, 3]);

    List output = List.generate(1, (index) => List.filled(192, 0));

    interpreter = await tfl.Interpreter.fromAsset('lib/mobilefacenet.tflite',
        options: tfl.InterpreterOptions());

    interpreter.run(input, output);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("input compare")));

    output = output.reshape([192]);

    predictedArray = List.from(output);

    if (!loginUser) {
      SharedData().setFace(predictedArray!);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Predicted table is saved ${loginUser.toString()}")));
      // LocalDB.setUserDetails(User(name: name, array: predictedArray!));
      return false;
    } else {
      // User? user = LocalDB.getUser();
      // List userArray = user.array!;
      List savedArr = await SharedData().getFace();

      double minDist = 999;
      double currDist = 0.0;
      double threshold = 1;
      print("Predicted" +
          predictedArray.toString() +
          "old array" +
          savedArr.toString());
      currDist = euclideanDistance(predictedArray, savedArr);
      print("dist" + currDist.toString());
      if (currDist <= threshold && currDist < minDist) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("face matched ")));
        return true;
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("face not matched ")));
        return false;
      }
    }
  }

  euclideanDistance(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  List _preProcess(CameraImage image, Face faceDetected) {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);

    Float32List imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = imglib.copyRotate(img!, -90);
    return img1;
  }

  Float32List _imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }
}
