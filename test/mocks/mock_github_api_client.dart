import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:github_accounts_explorer/data/datasources/github_api_client.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

@GenerateMocks([GitHubApiClient, http.Client, FlutterSecureStorage])
void main() {}
