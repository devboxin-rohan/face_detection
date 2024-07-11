import 'package:camera/camera.dart';
import 'package:detect_face/ml_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image/image.dart' as imglib;
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _HomePageState();
}

class _HomePageState extends State<RegistrationScreen> {
  //TODO declare variables
  TextEditingController controller = TextEditingController();
  late List<CameraDescription> cameras;

  late CameraController cameraController;

  bool flash = false;
  InputImage? inputImage;

  late FaceDetector _faceDetector;
  // final MLService _mlService = MLService();
  List<Face> facesDetected = [];

  bool _cameraInitialized = false;

  void startCamera() async {
    cameras = await availableCameras();

    cameraController = CameraController(
      cameras[1],
      ResolutionPreset.high,
    );

    print(" Camera controller : $cameraController");

    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cameraInitialized =
            true; // updating the flag after camera is initialized
      }); //To refresh widget
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void initState() {
    super.initState();

    // _cameraController = CameraController(cameras![1], ResolutionPreset.high);
    // initializeCamera();
    imagePicker = ImagePicker();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

    // });
  }

  late ImagePicker imagePicker;
  // File? _image;
  // String text = "";

  // //TODO declare detector
  // final options = FaceDetectorOptions();
  // late final faceDetector = FaceDetector(options: options);
  // //TODO declare face recognizer

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   imagePicker = ImagePicker();

  //   //TODO initialize face detector

  //   //TODO initialize face recognizer
  // }

  // //TODO capture image using camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        inputImage = InputImage.fromFilePath(pickedFile.path);
      });
      // doFaceDetection();
    }
  }

  // //TODO choose image using gallery
  // _imgFromGallery() async {
  //   XFile? pickedFile =
  //       await imagePicker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //     doFaceDetection(InputImage.fromFilePath(pickedFile.path));
  //   }
  // }

  // //TODO face detection code here
  String text = "";
  Face? face;
  doFaceDetection(path) async {
    final List<Face> faces =
        await _faceDetector.processImage(InputImage.fromFilePath(path)!);
    setState(() {
      text = faces[0].boundingBox.toString();
      face = faces[0];
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("inside save saved")));
    if (faces.isNotEmpty) {
      CameraImage? getCameraImg;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Face found")));
      cameraController.startImageStream((CameraImage image) async {
        setState(() {
          getCameraImg = image;
        });
        cameraController.stopImageStream();

        await MLService()
            .predict(context, image, faces[0], false, "Random")
            .then((value) {
          cameraController.stopImageStream();
        });
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Face not found")));
      print("No faces found please retake photo");
    }
  }

  // //TODO remove rotation of camera images
  // removeRotation(File inputImage) async {
  //   final img.Image? capturedImage =
  //       img.decodeImage(await File(inputImage!.path).readAsBytes());
  //   final img.Image orientedImage = img.bakeOrientation(capturedImage!);
  //   return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
  // }

  // //TODO perform Face Recognition

  // //TODO Face Registration Dialogue
  // TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      height: 250,
      child: Column(
        children: [
          Text(text),
          SizedBox(
            width: 130,
            height: 130,
            child: _cameraInitialized ? CameraPreview(cameraController) : null,
          ),
          ElevatedButton(
              onPressed: () {
                startCamera();
              },
              child: Text("start Camera")),
          ElevatedButton(
              onPressed: () {
                // _imgFromCamera();
                cameraController.stopImageStream();
                cameraController.takePicture().then((image) async {
                  doFaceDetection(image.path);
                });
              },
              child: Text("Register"))
        ],
      ),
    );
  }
}
