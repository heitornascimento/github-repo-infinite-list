import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class GithubRepo extends Equatable {
  final String name;
  final String fullName;
  final bool isPrivate;
  final int startCount;
  final int watcherCount;
  final String userName;
  final String avatarUrl;

  const GithubRepo(
      {required this.name,
      required this.fullName,
      required this.isPrivate,
      required this.startCount,
      required this.watcherCount,
      required this.userName,
      required this.avatarUrl});

  @override
  List<Object?> get props =>
      [name, fullName, isPrivate, startCount, watcherCount, userName, avatarUrl];
}

class GithubRepos {
  List<GithubRepo> repos;
  int totalCount;

  GithubRepos({required this.repos, required this.totalCount});
}
