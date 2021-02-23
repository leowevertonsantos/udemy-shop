import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';

enum AuthMode { Signup, Signin }

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final TextEditingController _passwordController = TextEditingController();
  AuthMode authMode = AuthMode.Signin;
  GlobalKey<FormState> _formKey = GlobalKey();
  bool isLoading = false;

  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    Auth auth = Provider.of<Auth>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    _formKey.currentState.save();

    if (authMode == AuthMode.Signin) {
      // Cadastrar
      await auth.signin(_authData['email'], _authData['password']);
    } else {
      await auth.signup(_authData['email'], _authData['password']);

      // Registrar
    }

    setState(() {
      isLoading = false;
    });
  }

  void _switchAuthMode() {
    setState(() {
      authMode =
          authMode == AuthMode.Signin ? AuthMode.Signup : AuthMode.Signin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        width: size.width * 0.75,
        // height: 330,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isEmpty || !value.contains("@")) {
                    return 'Informe um email válido.';
                  }

                  return null;
                },
                onSaved: (value) => _authData['email'] = value,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty || value.length < 5) {
                    return 'Informe uma senha válida.';
                  }

                  return null;
                },
                onSaved: (value) => _authData['password'] = value,
              ),
              if (authMode == AuthMode.Signup)
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmação de senha',
                  ),
                  keyboardType: TextInputType.text,
                  validator: authMode == AuthMode.Signup
                      ? (value) {
                          if (value.isEmpty ||
                              _passwordController.text != value) {
                            return 'A confirmação de senha não bate com a senha informada.';
                          }

                          return null;
                        }
                      : null,
                ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        authMode == AuthMode.Signin ? 'ENTRAR' : 'REGISTRAR',
                      ),
                      onPressed: _submit,
                    ),
              if (!isLoading)
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                    'ALTERNAR PARA ' +
                        (authMode == AuthMode.Signin ? 'REGISTRAR' : 'ENTRAR'),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
