import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class UpdateInfo {
  final bool isAvailable;
  final String? version;
  final String? downloadUrl;
  final String? releaseNotes;

  UpdateInfo({
    required this.isAvailable,
    this.version,
    this.downloadUrl,
    this.releaseNotes,
  });
}

class UpdateService {
  static const String _owner = 'udaykumar-dhokia';
  static const String _repo = 'jjjf-app';
  static const String _apiUrl =
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  final Dio _dio = Dio();

  Future<UpdateInfo> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionString = packageInfo.version;

      final response = await _dio.get(
        _apiUrl,
        options: Options(headers: {'Accept': 'application/vnd.github.v3+json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String latestVersionString = data['tag_name'] ?? '';

        if (latestVersionString.startsWith('v') ||
            latestVersionString.startsWith('V')) {
          latestVersionString = latestVersionString.substring(1);
        }

        final currentVersion = Version.parse(currentVersionString);
        final latestVersion = Version.parse(latestVersionString);

        if (latestVersion > currentVersion) {
          String? downloadUrl;
          final assets = data['assets'] as List<dynamic>?;
          if (assets != null) {
            for (var asset in assets) {
              final name = asset['name']?.toString().toLowerCase() ?? '';
              if (name.endsWith('.apk')) {
                downloadUrl = asset['browser_download_url'];
                break;
              }
            }
          }

          if (downloadUrl != null) {
            return UpdateInfo(
              isAvailable: true,
              version: latestVersionString,
              downloadUrl: downloadUrl,
              releaseNotes: data['body'],
            );
          }
        }
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }

    return UpdateInfo(isAvailable: false);
  }

  Future<String?> downloadUpdate(
    String url,
    Function(double) onProgress,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/app_update.apk';

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      return filePath;
    } catch (e) {
      print('Error downloading update: $e');
      return null;
    }
  }

  Future<void> installUpdate(String filePath) async {
    try {
      await OpenFilex.open(filePath);
    } catch (e) {
      print('Error installing update: $e');
    }
  }
}
