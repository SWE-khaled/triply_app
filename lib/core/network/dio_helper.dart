import 'package:dio/dio.dart';

import 'api_const.dart';

class DioHelper {
  static late Dio dio;

  void initialization() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConst.baseUrl,
        headers: {
          "Content-Type": "application/json",
        },
        receiveDataWhenStatusError: true,
      ),
    );
  }

  Future<Response> getData(String path) async {
    return await dio.get(path);
  }

  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? data,
  }) async {
    return await dio.post(url, data: data);
  }
  Future<Response> putData(
      String path, {
        required dynamic data,
      }) async {
    return await dio.put(path, data: data);
  }

  Future<Response> deleteData(String path) async {
    return await dio.delete(path);
  }
}

