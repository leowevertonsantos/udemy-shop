import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as httpClient;

class Auth with ChangeNotifier {
  Future<void> signup(String email, String password) async {
    return this._authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return this._authenticate(email, password, 'signInWithPassword');
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:${urlSegment}?key=AIzaSyC0iO7e1DeUnQ6oB0rRMleGLNMIGloP25E';

    final response = await httpClient.post(
      url,
      body: json.encode(
        {
          "email": email,
          "password": password,
          "returnSecureToken": true,
        },
      ),
    );

    print(json.decode(response.body));
    return Future.value();
  }
}
