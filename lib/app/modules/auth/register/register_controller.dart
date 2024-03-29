import 'package:cuidapet_mobile/app/core/exceptions/user_exists_exception.dart';
import 'package:cuidapet_mobile/app/core/helpers/logger.dart';
import 'package:cuidapet_mobile/app/core/ui/widgets/loader.dart';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../../../services/user/user_service.dart';
import '../../../core/ui/widgets/messages.dart';

part 'register_controller.g.dart';

class RegisterController = RegisterControllerBase with _$RegisterController;

abstract class RegisterControllerBase with Store {
  final UserService _userService;
  final Logger _log;

  RegisterControllerBase({
    required UserService userService,
    required Logger log,
  })  : _userService = userService,
        _log = log;

  Future<void> register(String email, String password) async {
    try {
      Loader.show();
      await _userService.register(email, password);
      Loader.hide();
      Modular.to.popAndPushNamed('/auth/');
    } on UserExistsException {
      Loader.hide();
      Messages.alert('E-mail já utilizado, por favor escolha outro e-mail');
    } catch (e, s) {
      _log.error('Erro ao registrar usuário', e, s);
      Loader.hide();
      Messages.alert('Erro ao registrar usuário, tente novamente mais tarde');
    }
  }
}
