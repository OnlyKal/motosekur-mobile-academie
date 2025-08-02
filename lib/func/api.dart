import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// const String apiBase = 'http://localhost:8000/';
const String apiBase = 'https://api.motosekur.online/';

Future postData(String endpoint, Map<String, dynamic> body) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  var response = await http.post(
    Uri.parse('$apiBase$endpoint'),
    headers: {'Content-Type': 'application/json', 'Authorization': token ?? ''},
    body: jsonEncode(body),
  );
  print(response.body);
  return response.statusCode == 200 || response.statusCode == 201
      ? jsonDecode(response.body)
      : null;
}

Future patchData(String endpoint, Map<String, dynamic> body) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  var response = await http.patch(
    Uri.parse('$apiBase$endpoint'),
    headers: {'Content-Type': 'application/json', 'Authorization': token ?? ''},
    body: jsonEncode(body),
  );

  return response.statusCode == 200 ? jsonDecode(response.body) : null;
}

Future getData(endpoint) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var response = await http.get(
      Uri.parse('$apiBase$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token ?? '',
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  } catch (e) {
    return null;
  }
}

Future deleteData(endpoint) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var response = await http.delete(
      Uri.parse('$apiBase$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token ?? '',
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  } catch (e) {
    return null;
  }
}
