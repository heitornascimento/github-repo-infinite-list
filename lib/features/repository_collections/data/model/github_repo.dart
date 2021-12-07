import 'package:flutter/foundation.dart';

class GithubRepo {
  final String name;
  final String fullName;
  final bool isPrivate;
  final int startCount;
  final int watcherCount;
  final String htmlUrl;
  final int id;
  final String nodeId;
  final String userName;
  final String avatarUrl;

  GithubRepo(
      {required this.name,
      required this.fullName,
      required this.isPrivate,
      required this.startCount,
      required this.watcherCount,
      required this.htmlUrl,
      required this.id,
      required this.nodeId,
      required this.userName,
      required this.avatarUrl});

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    String _name = json['name'];
    String _fullName = json['full_name'];
    bool _isPrivate = json['private'];
    int _startCount = json['stargazers_count'];
    int _watcherCount = json['watchers_count'];
    String _htmlUrl = json['html_url'];
    int _id = json['id'];
    String _nodeId = json['node_id'];
    String _userName = json["owner"]["login"];
    String _avatarUrl = json["owner"]["avatar_url"];

    return GithubRepo(
        name: _name,
        fullName: _fullName,
        isPrivate: _isPrivate,
        startCount: _startCount,
        watcherCount: _watcherCount,
        htmlUrl: _htmlUrl,
        id: _id,
        nodeId: _nodeId,
        userName: _userName,
        avatarUrl: _avatarUrl);
  }
}
