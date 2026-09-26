import 'dart:math';

import 'package:dio/dio.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infraestructure/models/yes_no_model.dart';

class GetYesNoAnswer {
  final _random = Random();

  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Message> getAnswer() async {
    // Genera un entero entre 0 y 99.
    final number = _random.nextInt(100);

    final String answer;

    if (number < 40) {
      answer = 'yes'; // 0 a 39: 40 %
    } else if (number < 80) {
      answer = 'no'; // 40 a 79: 40 %
    } else {
      answer = 'maybe'; // 80 a 99: 20 %
    }

    var image = '';

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://yesno.wtf/api',
        queryParameters: {'force': answer},
      );

      final data = response.data;

      if (data != null &&
          data['answer'] == answer &&
          data['image'] is String) {
        image = data['image'] as String;
      }
    } on DioException {
      // Si falla Internet, conservamos la respuesta de texto.
      // Simplemente no se mostrará un GIF.
    }

    return YesNoModel(
      answer: answer,
      forced: true,
      image: image,
    ).toMessageEntity();
  }

  void dispose() {
    _dio.close(force: true);
  }
}