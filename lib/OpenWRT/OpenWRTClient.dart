import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:openwrt_manager/Model/Identity.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWRT/Model/AuthenticateReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWRT/Model/ReplyBase.dart';
import 'package:openwrt_manager/OpenWRT/Model/DeleteClientReply.dart';
import 'Model/SystemInfoReply.dart';

class OpenWRTClient {
  Identity _identity;
  Device _device;

  static const int Timeout = 3;

  String get _baseURL {
    String url;
    if (_device.useSecureConnection)
      url = "https://${_device.address}";
    else
      url = "http://${_device.address}";
    if (_device.port.length > 0) url += ":" + _device.port;
    return url;
  }

  OpenWRTClient(Device d, Identity i) {
    _identity = i;
    _device = d;
  }

  HttpClient _getClient() {
    var cli = HttpClient();
    if (_device.ignoreBadCertificate)
      cli.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    return cli;
  }

  Future<List<CommandReplyBase>> getData(
      Cookie c, List<CommandReplyBase> commands) async {
    var http = _getClient();
    http.connectionTimeout = Duration(seconds: Timeout);

    try {
      var request =
          await http.postUrl(Uri.parse(_baseURL + "/cgi-bin/luci/admin/ubus"));
      var data = List<Map<String, Object>>();
      var counter = 1;
      for (var cmd in commands) {
        List<Object> params = ["${c.value}"];
        for (var prm in cmd.commandParameters) {
          params.add(prm);
        }
        if (params.length < 4) params.add({});
        var jsonRPC = {
          "jsonrpc": "2.0",
          "id": counter++,
          "method": "call",
          "params": params
        };
        data.add(jsonRPC);
      }

      request.headers.set('content-type', 'application/json');
      var jsonText = json.encode(data);
      var body = utf8.encode(jsonText);
      request.contentLength = body.length;
      request.add(body);

      HttpClientResponse response =
          await request.close().timeout(const Duration(seconds: Timeout));
      http.close();
      if (response.statusCode == 200) {
        var jsonText = await response.transform(utf8.decoder).join();
        var jsonData = (json.decode(jsonText) as List<dynamic>)
            .map((x) => x as Map<String, Object>);
        var lstResponse = List<CommandReplyBase>();
        var idCounter = 1;
        for (var cmd in commands) {
          var cmdData = jsonData.firstWhere((x) => x["id"] as int == idCounter);
          lstResponse.add(cmd.createReply(ReplyStatus.Ok, cmdData));
          idCounter++;
        }
        return Future.value(lstResponse);
      } else if (response.statusCode == 403)
        return Future.value([SystemInfoReply(ReplyStatus.Forbidden)]);
      else if (response.statusCode == 404)
        return Future.value([SystemInfoReply(ReplyStatus.NotFound)]);
    } on Exception {
      return Future.value([SystemInfoReply(ReplyStatus.Error)]);
    }
    return Future.value([SystemInfoReply(ReplyStatus.Error)]);
  }

  Future<DeleteClientReply> deleteClient(
      AuthenticateReply auth, String interfaceName, String mac) async {
    try {
      var cmd = DeleteClientReply(ReplyStatus.Ok);
      cmd.interfaceName = interfaceName;
      cmd.mac = mac;
      var res = await getData(auth.authenticationCookie, [cmd]);
      var data = res[0] as DeleteClientReply;
      if ((data.data["result"] as List)[0] == 0)
        return Future.value(data);
      else
        return DeleteClientReply(ReplyStatus.Error);
    } catch (e) {      
      return Future.value(DeleteClientReply(ReplyStatus.Error));
    }
  }

  Future<AuthenticateReply> authenticate() async {
    var http = _getClient();
    http.connectionTimeout = Duration(seconds: Timeout);
    try {
      var request = await http.postUrl(Uri.parse(_baseURL + "/cgi-bin/luci/"));
      var params =
          "luci_username=${_identity.username}&luci_password=${_identity.password}";
      var body = utf8.encode(params);
      request.headers.set('content-type', 'application/x-www-form-urlencoded');
      request.contentLength = body.length;
      request.add(body);

      HttpClientResponse response =
          await request.close().timeout(const Duration(seconds: 10));
      http.close();
      if (response.statusCode == 302) {
        for (var c in response.cookies) {
          if (c.name == "sysauth")
            return Future.value(AuthenticateReply(ReplyStatus.Ok, c));
        }
      }
      return Future.value(AuthenticateReply(ReplyStatus.Forbidden, null));
    } on HandshakeException catch (ex) {
      debugPrint(ex.toString());
      return Future.value(AuthenticateReply(ReplyStatus.HandshakeError, null));
    } on Exception catch (ex) {
      debugPrint(ex.toString());
      return Future.value(AuthenticateReply(ReplyStatus.Timeout, null));
    }
  }
}
