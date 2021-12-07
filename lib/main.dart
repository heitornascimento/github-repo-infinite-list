import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:github_repos/features/repository_collections/data/remote/core/github_api.dart';
import 'package:github_repos/features/repository_collections/data/remote/github_repository.dart';
import 'package:github_repos/features/repository_collections/data/remote/core/http_client.dart';
import 'package:github_repos/features/repository_collections/domain/get_github_repositories.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_bloc.dart';
import 'package:github_repos/github_app.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>(create: (_) => Dio()),
        ProxyProvider<Dio, HttpClient>(
            update: (_, dio, __) => HttpClient.dio(dio)),
        ProxyProvider<HttpClient, GithubAPI>(
            update: (_, client, __) => GithubAPI(client: client)),
        ProxyProvider<GithubAPI, GithubRepository>(
            update: (_, api, __) => GithubRepository(api: api)),
        ProxyProvider<GithubRepository, GetGithubRepositories>(
            update: (_, repository, __) => GetGithubRepositories(repository)),
        ProxyProvider<GetGithubRepositories, RepoBLoc>(
            update: (_, useCase, __) => RepoBLoc(useCase: useCase)),
      ],
      child: const GithubApp(),
    ),
  );
}
