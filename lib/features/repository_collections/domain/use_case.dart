

import 'package:dartz/dartz.dart';
import 'package:github_repos/features/repository_collections/domain/model/github_repo.dart';

abstract class UseCase<T, P, P2>{

  const UseCase();

  Future<Either<Exception,GithubRepos>> execute([P param1, P2 param2]);

}