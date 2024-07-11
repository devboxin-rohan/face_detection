import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedData {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void setFace(List faceArr) async {
    final SharedPreferences prefs = await _prefs;
    var stringArr = faceArr.map((i) => i.toString()).join(",");
    prefs.setString("face", stringArr);
  }

  Future<List> getFace() async {
    final SharedPreferences prefs = await _prefs;
    String facelist = prefs.getString("face") ?? "";
    return facelist.split(",").map(num.parse).toList();
  }

  void setDashboardDetail(data) async {
    final SharedPreferences prefs = await _prefs;
    String stringData = jsonEncode(data);
    prefs.setString("dashboard_detail", stringData);
  }

  Future<String> getDashboardDetail() async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString("dashboard_detail") ?? "";
    return token;
  }

  void setDeviceId(token) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("device_id", token);
  }

  Future<String> getDeviceId() async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString("device_id") ?? "";
    return token;
  }
}
