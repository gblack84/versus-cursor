import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class SearchAlgoliaCall {
  static Future<ApiCallResponse> call() async {
    final ffApiRequestBody = '''
{
  "query": "검색어"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'SearchAlgolia',
      apiUrl:
          'https://0GAS0MPT9Z-dsn.algolia.net/1/indexes/jops_category/query',
      callType: ApiCallType.POST,
      headers: {
        'X-Algolia-API-Key': '123e265bbab0702b220a66a59f22ab8e',
        'X-Algolia-Application-Id': '0GAS0MPT9Z',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetUploadUrlCall {
  static Future<ApiCallResponse> call() async {
    final ffApiRequestBody = '''
{
  "fileName": "<fileName>",
  "contentType": "<contentType>"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'getUploadUrl',
      apiUrl:
          'https://encoder-636984750551.asia-northeast3.run.app/generate-upload-url',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class RequestEncodingCall {
  static Future<ApiCallResponse> call() async {
    final ffApiRequestBody = '''
{
  "gcsPath": "<gcsPath>",
  "thumbUrl": "<thumbUrl>",
  "postId": "<postId>",
  "docId": "<docId>",
  "ownerUid": "<ownerUid>",
  "start_ms": <startMs>,
  "end_ms": <endMs>,
  "rotate": 0,
  "crop": null
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'requestEncoding',
      apiUrl: 'https://encoder-636984750551.asia-northeast3.run.app/encode',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
