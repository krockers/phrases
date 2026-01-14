import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:language_practice_app/models/sentence.dart';

class GoogleSheetsRepository {
  final AuthClient _authClient;
  late final sheets.SheetsApi _sheetsApi;

  GoogleSheetsRepository(this._authClient) {
    _sheetsApi = sheets.SheetsApi(_authClient);
  }

  Future<List<List<dynamic>>> fetchAllRows(
    String spreadsheetId, {
    String sheetName = 'Sentences',
  }) async {
    try {
      final range = '$sheetName!A2:I';

      final response = await _sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        range,
      );

      return response.values ?? [];
    } catch (e) {
      throw Exception('Failed to fetch rows from Google Sheets: $e');
    }
  }

  Future<List<Sentence>> fetchAllSentences(String spreadsheetId) async {
    try {
      final rows = await fetchAllRows(spreadsheetId);
      return rows.map((row) => Sentence.fromSheetRow(row)).toList();
    } catch (e) {
      throw Exception('Failed to fetch sentences from Google Sheets: $e');
    }
  }

  Future<void> updateRow(
    String spreadsheetId,
    int rowIndex,
    List<dynamic> values, {
    String sheetName = 'Sentences',
  }) async {
    try {
      final range = '$sheetName!A$rowIndex:I$rowIndex';

      final valueRange = sheets.ValueRange()..values = [values];

      await _sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      throw Exception('Failed to update row in Google Sheets: $e');
    }
  }

  Future<void> updateRows(
    String spreadsheetId,
    List<Sentence> sentences, {
    String sheetName = 'Sentences',
  }) async {
    try {
      final rows = await fetchAllRows(spreadsheetId);
      final updates = <sheets.ValueRange>[];

      for (var sentence in sentences) {
        final rowIndex = rows.indexWhere((row) => row[0] == sentence.id);

        if (rowIndex != -1) {
          final actualRowNumber = rowIndex + 2;
          final range = '$sheetName!A$actualRowNumber:I$actualRowNumber';

          final valueRange = sheets.ValueRange()
            ..range = range
            ..values = [sentence.toSheetRow()];

          updates.add(valueRange);
        }
      }

      if (updates.isNotEmpty) {
        final batchUpdate = sheets.BatchUpdateValuesRequest()
          ..data = updates
          ..valueInputOption = 'USER_ENTERED';

        await _sheetsApi.spreadsheets.values.batchUpdate(
          batchUpdate,
          spreadsheetId,
        );
      }
    } catch (e) {
      throw Exception('Failed to update rows in Google Sheets: $e');
    }
  }

  Future<void> appendRow(
    String spreadsheetId,
    List<dynamic> values, {
    String sheetName = 'Sentences',
  }) async {
    try {
      final range = '$sheetName!A:I';

      final valueRange = sheets.ValueRange()..values = [values];

      await _sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      throw Exception('Failed to append row to Google Sheets: $e');
    }
  }

  Future<void> appendRows(
    String spreadsheetId,
    List<List<dynamic>> rows, {
    String sheetName = 'Sentences',
  }) async {
    try {
      final range = '$sheetName!A:I';

      final valueRange = sheets.ValueRange()..values = rows;

      await _sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      throw Exception('Failed to append rows to Google Sheets: $e');
    }
  }

  Future<void> appendSentences(
    String spreadsheetId,
    List<Sentence> sentences,
  ) async {
    try {
      final rows = sentences.map((s) => s.toSheetRow()).toList();
      await appendRows(spreadsheetId, rows);
    } catch (e) {
      throw Exception('Failed to append sentences to Google Sheets: $e');
    }
  }

  Future<void> deleteRow(
    String spreadsheetId,
    int rowIndex, {
    String sheetName = 'Sentences',
  }) async {
    try {
      final sheetId = await _getSheetId(spreadsheetId, sheetName);

      final request = sheets.Request()
        ..deleteDimension = (sheets.DeleteDimensionRequest()
          ..range = (sheets.DimensionRange()
            ..sheetId = sheetId
            ..dimension = 'ROWS'
            ..startIndex = rowIndex - 1
            ..endIndex = rowIndex));

      final batchUpdate = sheets.BatchUpdateSpreadsheetRequest()
        ..requests = [request];

      await _sheetsApi.spreadsheets.batchUpdate(batchUpdate, spreadsheetId);
    } catch (e) {
      throw Exception('Failed to delete row from Google Sheets: $e');
    }
  }

  Future<int> _getSheetId(String spreadsheetId, String sheetName) async {
    try {
      final spreadsheet = await _sheetsApi.spreadsheets.get(spreadsheetId);

      final sheet = spreadsheet.sheets?.firstWhere(
        (s) => s.properties?.title == sheetName,
        orElse: () => throw Exception('Sheet "$sheetName" not found'),
      );

      return sheet?.properties?.sheetId ?? 0;
    } catch (e) {
      throw Exception('Failed to get sheet ID: $e');
    }
  }

  Future<void> createSheet(
    String spreadsheetId,
    String sheetName,
  ) async {
    try {
      final request = sheets.Request()
        ..addSheet = (sheets.AddSheetRequest()
          ..properties = (sheets.SheetProperties()..title = sheetName));

      final batchUpdate = sheets.BatchUpdateSpreadsheetRequest()
        ..requests = [request];

      await _sheetsApi.spreadsheets.batchUpdate(batchUpdate, spreadsheetId);
    } catch (e) {
      throw Exception('Failed to create sheet: $e');
    }
  }

  Future<void> initializeSheet(String spreadsheetId) async {
    try {
      const sheetName = 'Sentences';

      try {
        await _getSheetId(spreadsheetId, sheetName);
      } catch (e) {
        await createSheet(spreadsheetId, sheetName);
      }

      final headers = [
        'id',
        'audio_filename',
        'original_text',
        'translation',
        'repetitions',
        'last_practiced',
        'drive_file_id',
        'created_at',
        'updated_at',
      ];

      final range = '$sheetName!A1:I1';
      final valueRange = sheets.ValueRange()..values = [headers];

      await _sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      throw Exception('Failed to initialize sheet: $e');
    }
  }

  Future<bool> spreadsheetExists(String spreadsheetId) async {
    try {
      await _sheetsApi.spreadsheets.get(spreadsheetId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
