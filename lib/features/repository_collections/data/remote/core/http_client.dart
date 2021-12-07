import 'package:dio/dio.dart';
import 'package:github_repos/features/repository_collections/data/remote/core/helpers.dart';

class HttpClient {
  Dio dio;
  String searchPathParam = '/search/repositories' ;

  String get searchPath {
    return  searchPathParam;
  }

  set searchPath(String path){
    searchPathParam = path;
  }

  HttpClient(this.dio);


  factory HttpClient.dio(Dio dio, [String url = GITHUB_REPO_URL]) {
    dio.options.baseUrl = url;
    dio.interceptors.add(CustomInterceptors());
    return HttpClient(dio);
  }

  dynamic get(String path, Map<String, dynamic> queryParameter ) async  {
      Response response =  await dio.get(path, queryParameters: queryParameter);
      return response.data;
  }
}

class CustomInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST ${options.uri.toString()} [${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
     super.onResponse(response, handler);
  }
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print('ERROR ${err.message}    ${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
     super.onError(err, handler);
  }
}
