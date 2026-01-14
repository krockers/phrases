import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class GoogleDriveRepository {
  final AuthClient _authClient;
  late final drive.DriveApi _driveApi;

  GoogleDriveRepository(this._authClient) {
    _driveApi = drive.DriveApi(_authClient);
  }

  Future<List<drive.File>> listFilesInFolder(String folderId) async {
    try {
      final response = await _driveApi.files.list(
        q: "'$folderId' in parents and trashed = false",
        $fields: 'files(id, name, mimeType, modifiedTime, size)',
        orderBy: 'name',
      );

      return response.files ?? [];
    } catch (e) {
      throw Exception('Failed to list files in folder: $e');
    }
  }

  Future<drive.File> getFileMetadata(String fileId) async {
    try {
      return await _driveApi.files.get(
        fileId,
        $fields: 'id, name, mimeType, modifiedTime, size, webContentLink',
      ) as drive.File;
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }

  Future<String> downloadFile(
    String fileId,
    String fileName, {
    Function(int, int)? onProgress,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${appDir.path}/audio');

      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final filePath = '${audioDir.path}/$fileName';

      final metadata = await getFileMetadata(fileId);
      final webContentLink = metadata.webContentLink;

      if (webContentLink == null) {
        throw Exception('File does not have a download link');
      }

      final dio = Dio();

      await dio.download(
        'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
        filePath,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_authClient.credentials.accessToken.data}',
          },
        ),
        onReceiveProgress: (received, total) {
          if (onProgress != null && total != -1) {
            onProgress(received, total);
          }
        },
      );

      return filePath;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  Future<List<String>> downloadMultipleFiles(
    List<Map<String, String>> files, {
    Function(int, int)? onOverallProgress,
  }) async {
    final downloadedPaths = <String>[];
    int completedFiles = 0;
    final totalFiles = files.length;

    for (var file in files) {
      final fileId = file['id']!;
      final fileName = file['name']!;

      try {
        final path = await downloadFile(fileId, fileName);
        downloadedPaths.add(path);
        completedFiles++;

        if (onOverallProgress != null) {
          onOverallProgress(completedFiles, totalFiles);
        }
      } catch (e) {
        print('Failed to download $fileName: $e');
      }
    }

    return downloadedPaths;
  }

  Future<bool> fileExists(String fileId) async {
    try {
      await _driveApi.files.get(fileId, $fields: 'id');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> createFolder(String folderName, {String? parentId}) async {
    try {
      final folder = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder';

      if (parentId != null) {
        folder.parents = [parentId];
      }

      final createdFolder = await _driveApi.files.create(folder);
      return createdFolder.id!;
    } catch (e) {
      throw Exception('Failed to create folder: $e');
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      await _driveApi.files.delete(fileId);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<drive.File> uploadFile(
    File file,
    String fileName,
    String folderId,
  ) async {
    try {
      final driveFile = drive.File()
        ..name = fileName
        ..parents = [folderId];

      final media = drive.Media(file.openRead(), file.lengthSync());

      final uploadedFile = await _driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );

      return uploadedFile;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}
