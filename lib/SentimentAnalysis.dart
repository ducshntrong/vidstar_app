import 'package:tflite_flutter/tflite_flutter.dart';

class SentimentAnalysis {
  late Interpreter _interpreter;

  SentimentAnalysis() {
    _loadModel();
  }

  void _loadModel() async {
    _interpreter = await Interpreter.fromAsset('model.tflite');
  }

  // Hàm để dự đoán cảm xúc
  Future<double> predict(String inputText) async {
    // Tiền xử lý văn bản (cần tùy chỉnh theo mô hình)
    var input = _preprocess(inputText);
    var output = List.filled(1, 0.0).reshape([1, 1]);

    _interpreter.run(input, output);

    return output[0][0]; // Giá trị dự đoán
  }

  List<List<double>> _preprocess(String text) {
    // Chuyển đổi văn bản thành định dạng mà mô hình yêu cầu
    // Cần tùy chỉnh theo yêu cầu của mô hình (như tokenization, padding, v.v.)
    // Ví dụ: trả về một mảng số cho mỗi từ
    return [[0.0]]; // Thay thế bằng cách xử lý thực tế
  }

  void dispose() {
    _interpreter.close();
  }
}