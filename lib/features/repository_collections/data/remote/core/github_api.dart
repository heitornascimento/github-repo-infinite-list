import 'dart:convert' as convert;

import 'package:dio/dio.dart';
import 'package:github_repos/features/repository_collections/data/remote/core/http_client.dart';
import 'package:http/http.dart' as http;

//search/repositories?q=flutter&page=1&per_page=2
class GithubAPI {
  HttpClient client;

  GithubAPI({required this.client});

  dynamic fetchRepoByName(String name, int page) async {
    Map<String, dynamic> queryParameter = {'q': name, 'page': page};
    final result = await client.get(client.searchPath, queryParameter);
    return result;
  }
}
