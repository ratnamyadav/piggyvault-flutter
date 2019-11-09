import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:piggy_flutter/models/api_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piggy_flutter/utils/uidata.dart';

class RestClient {
  static const ApiEndpointUrl = "http://10.0.2.2:21021/api";

  Future<AjaxResponse<T>> getAsync<T>(String resourcePath) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(UIData.authToken);
    var tenantId = prefs.getInt(UIData.tenantId);
    var response = await http.get('$ApiEndpointUrl/$resourcePath', headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Abp.TenantId': tenantId.toString()
    });
    return processResponse<T>(response);
  }

  Future<AjaxResponse<T>> postAsync<T>(
      String resourcePath, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(UIData.authToken);
    var tenantId = prefs.getInt(UIData.tenantId);

    var content = json.encoder.convert(data);
    // print(content);
    var response = await http
        .post('$ApiEndpointUrl/$resourcePath', body: content, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Abp.TenantId': tenantId.toString()
    });
    return processResponse<T>(response);
  }

  AjaxResponse<T> processResponse<T>(http.Response response) {
    try {
      // if (!((response.statusCode < 200) ||
      //     (response.statusCode >= 300) ||
      //     (response.body == null))) {
      var jsonResult = response.body;
      dynamic resultClass = jsonDecode(jsonResult);

      // print(jsonResult);

      var output = AjaxResponse<T>(
        result: resultClass["result"],
        success: resultClass["success"],
        unAuthorizedRequest: resultClass['unAuthorizedRequest'],
      );

      if (!output.success) {
        output.error = resultClass["error"]["message"];
      }
      return output;
    } catch (e) {
      return AjaxResponse<T>(
          result: null,
          success: false,
          unAuthorizedRequest: false,
          error: 'Something went wrong. Please try again');
    }
  }
}
