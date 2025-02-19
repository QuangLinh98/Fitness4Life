import 'package:dio/dio.dart';
import 'package:fitness4life/token/token_manager.dart';

class ApiGateWayService {
  final Dio _dio;   //Cấu hình Dio để thêm Authorization Header vào mọi yêu cầu và xử lý lỗi khi token hết hạn.

  // Danh sách các endpoint không cần token
  static const  List<String> noAuthEndpoints = [
    "/users/login",
    "/users/register",
    "/users/verify-account/",
    "/users/send-otp",
    "/users/reset-password",
    "/users/refresh_token",
    "/booking/qrCode/validate",
    "/uploads/TrainerImage/"
  ];

  //Thêm token vào header cho mỗi yêu cầu.
  ApiGateWayService(this._dio) {
    _dio.interceptors.add(InterceptorsWrapper(
      // Xử lý trước khi gửi yêu cầu
      onRequest: (options, handler) async {
        print("Request Path: ${options.path}");
        print("Headers Before Adding Authorization: ${options.headers}");
        print("Full Path: ${_dio.options.baseUrl}${options.path}");

        // Kiểm tra nếu endpoint thuộc danh sách không cần token
        if (!noAuthEndpoints.any((endpoint) => options.path.startsWith(endpoint))) {
          String? token = await TokenManager.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print("Authorization Header: Bearer $token");
          } else {
            print("Token is null");
          }
        }else {
          print("No Authorization required for this endpoint: ${options.path}");
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
  Future<Response> postData(String endpoint, {Map<String, dynamic>? data, Options? options}) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            print("Response status: $status");
            return status != null && status < 500; // Cho phép 4xx phản hồi
          },
        ),
      );
      print("Response from backend: ${response.data}");
      return response;
    } catch (e) {
      print("Error in postData: $e");
      rethrow; // Để xử lý lỗi ở lớp trên
    }
  }

  Future<Response> postDataWithFormData(String endpoint, {FormData? formData, Options? options}) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );
      return response;
    } catch (e) {
      print("Error in postDataWithFormData: $e");
      rethrow;
    }
  }

  // Phương thức PUT
  Future<Response?> putData(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      print("Sending PUT request to: $endpoint");
      print("Data: ${data.toString()}");

      final response = await _dio.put(endpoint, data: data);

      print("Response: ${response.data}");
      return response;
    } catch (e) {
      print("Error in PUT request: $e");
      return null; // Trả về null nếu có lỗi
    }
  }


  // Phương thức DELETE
  Future<Response> deleteData(String endpoint, {Map<String, dynamic>? data}) async {
    return await _dio.delete(endpoint, data: data);
  }

}