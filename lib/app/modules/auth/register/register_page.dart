import 'package:cuidapet_mobile/app/core/ui/extensions/size_screen_extension.dart';
import 'package:cuidapet_mobile/app/core/ui/validators/validators.dart';
import 'package:cuidapet_mobile/app/core/ui/widgets/cuidapet_default_button.dart';
import 'package:cuidapet_mobile/app/core/ui/widgets/cuidapet_text_form_field.dart';
import 'package:cuidapet_mobile/app/modules/auth/register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:validatorless/validatorless.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState
    extends ModularState<RegisterPage, RegisterController> {
  final _formKey = GlobalKey<FormState>();
  final _loginEC = TextEditingController();
  final _passwordEC = TextEditingController();
  final _confirmpasswordEC = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _loginEC.dispose();
    _passwordEC.dispose();
    _confirmpasswordEC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastre-se'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(top: 1.statusBarHeight + 30, left: 20, right: 20),
          width: 1.sw,
          height: 1.sh - 1.statusBarHeight - kToolbarHeight,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150.w,
                  fit: BoxFit.fill,
                ),
                const SizedBox(
                  height: 10,
                ),
                CuidapetTextFormField(
                  label: 'Login',
                  controller: _loginEC,
                  validator: Validatorless.multiple([
                    Validatorless.required('Login obrigatório'),
                    Validatorless.email('E-mail inválido'),
                  ]),
                ),
                const SizedBox(
                  height: 10,
                ),
                CuidapetTextFormField(
                  label: 'Senha',
                  obscureText: true,
                  controller: _passwordEC,
                  validator: Validatorless.multiple([
                    Validatorless.required('Senha obrigatória'),
                    Validatorless.min(
                        6, 'Senha precisa ter pelo menos 6 caracteres')
                  ]),
                ),
                const SizedBox(
                  height: 10,
                ),
                CuidapetTextFormField(
                  label: 'Confirmar Senha',
                  obscureText: true,
                  controller: _confirmpasswordEC,
                  validator: Validatorless.multiple([
                    Validatorless.required('Confimar Senha obrigatória'),
                    Validatorless.min(
                        6, 'Senha precisa ter pelo menos 6 caracteres'),
                    Validators.compare(
                        _passwordEC, 'Senha e confirma senha não são iguais'),
                  ]),
                ),
                const SizedBox(
                  height: 10,
                ),
                CuidapetDefaultButton(
                  label: 'Cadastrar',
                  onPressed: () {
                    final formValid =
                        _formKey.currentState?.validate() ?? false;
                    if (formValid) {
                      controller.register(_loginEC.text, _passwordEC.text);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
