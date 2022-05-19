import 'package:cuidapet_mobile/app/core/ui/widgets/loader.dart';
import 'package:cuidapet_mobile/app/core/ui/widgets/messages.dart';
import 'package:cuidapet_mobile/app/models/social_type.dart';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../../../services/user/user_service.dart';
import '../../../core/exceptions/user_notfound_exception.dart';
import '../../../core/helpers/logger.dart';

part 'login_controller.g.dart';

class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store {
  final UserService _userService;
  final Logger _log;

  LoginControllerBase({
    required UserService userService,
    required Logger log,
  })  : _userService = userService,
        _log = log;

  Future<void> login(String login, String password) async {
    try {
      Loader.show();
      await _userService.login(login, password);
      Loader.hide();
      Modular.to.navigate('/auth/');
    } on UserNotfoundException {
      Loader.hide();
      Messages.alert('Login ou senha inválidos');
    } catch (e, s) {
      Loader.hide();
      _log.error('Erro ao ralizar login', e, s);
      Messages.alert('Erro ao ralizar login');
    }
  }

  Future<void> socialLogin(SocialType logintype) async {
    try {
      Loader.show();
      await _userService.socialLogin(logintype);
      Loader.hide();
      Modular.to.navigate('/auth/');
    } catch (e, s) {
      Loader.hide();
      _log.error('Erro ao ralizar login', e, s);
      Messages.alert('Erro ao ralizar login');
    }
  }
}
