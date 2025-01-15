import 'package:dio/dio.dart';
import 'package:fitness4life/features/user/data/service/token_manager.dart';

class ApiGateWayService {
  final Dio _dio;   //Cấu hình Dio để thêm Authorization Header vào mọi yêu cầu và xử lý lỗi khi token hết hạn.

  //Thêm token vào header cho mỗi yêu cầu.
  ApiGateWayService(this._dio) {
    _dio.interceptors.add(InterceptorsWrapper(
      // Xử lý trước khi gửi yêu cầu
      onRequest: (options, handler) async {
        String? token = await TokenManager.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print("Authorization Header: Bearer $token");
        }else {
          print("Token is null");
        }
        options.headers['Content-Type'] = 'application/json';
        return handler.next(options);
      },
      // Xử lý khi gặp lỗi
      onError: (error, handler) async {
        print("Error: ${error.message}");
        if (error.response?.statusCode == 401) {
          // Nếu token hết hạn, thử làm mới token
          bool tokenRefreshed = await _refreshToken();
          if (tokenRefreshed) {
            return handler.resolve(await _retry(error.requestOptions));
        }
        }
        return handler.next(error);
      },
    ));
  }

  // Tự động làm mới token khi hết hạn (HTTP 401)
  Future<bool> _refreshToken() async {
    try {
      String? refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await _dio.post('/users/refresh_token', data: {
        'refreshToken': refreshToken,
      });

      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];

      await TokenManager.saveTokens(newAccessToken, newRefreshToken);
      return true;
    } catch (e) {
      print("Failed to refresh token: $e");
      return false;
    }
  }

  // Gửi lại yêu cầu API khi token được làm mới
  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(
      requestOptions.path,
      options: options,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  // Phương thức GET
  Future<Response> getData(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(endpoint, queryParameters: queryParameters);
  }

  // Phương thức POST
  Future<Response> postData(String endpoint, {Map<String, dynamic>? data}) async {
    return await _dio.post(endpoint, data: data);
  }

  // Phương thức PUT
  Future<Response> putData(String endpoint, {Map<String, dynamic>? data}) async {
    return await _dio.put(endpoint, data: data);
  }

  // Phương thức DELETE
  Future<Response> deleteData(String endpoint, {Map<String, dynamic>? data}) async {
    return await _dio.delete(endpoint, data: data);
  }
}