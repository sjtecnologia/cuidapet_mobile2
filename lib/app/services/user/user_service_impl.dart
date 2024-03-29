import 'package:cuidapet_mobile/app/core/exceptions/failure.dart';
import 'package:cuidapet_mobile/app/core/helpers/constants.dart';
import 'package:cuidapet_mobile/app/core/helpers/logger.dart';
import 'package:cuidapet_mobile/app/core/local_storages/local_security_storage.dart';
import 'package:cuidapet_mobile/app/core/local_storages/local_storage.dart';
import 'package:cuidapet_mobile/app/models/social_network_model.dart';
import 'package:cuidapet_mobile/app/models/social_type.dart';
import 'package:cuidapet_mobile/app/repositories/social/social_repository.dart';
import 'package:cuidapet_mobile/app/repositories/user/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './user_service.dart';

class UserServiceImpl implements UserService {
  final UserRepository _userRepository;
  final Logger _log;
  final LocalStorage _localStorage;
  final LocalSecurityStorage _localSecurityStorage;
  final SocialRepository _socialRepository;

  UserServiceImpl(
      {required UserRepository userRepository,
      required Logger log,
      required LocalStorage localStorage,
      required LocalSecurityStorage localSecurityStorage,
      required SocialRepository socialRepository})
      : _userRepository = userRepository,
        _log = log,
        _localStorage = localStorage,
        _localSecurityStorage = localSecurityStorage,
        _socialRepository = socialRepository;

  @override
  Future<void> register(String email, String password) async {
    try {
      await _userRepository.register(email, password);
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e, s) {
      _log.error('Erro ao criar usuário no FirebaseAuth', e, s);
      throw Failure('Erro ao criar usuário no FirebaseAuth');
    }
  }

  @override
  Future<void> login(String login, String password) async {
    try {
      final accessToken = await _userRepository.login(login, password);
      _log.info('AccessToken: $accessToken');
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: login, password: password);
      await _saveAccessToken(accessToken);
      await _confirmLogin();
      await _getUserData();
      _log.info('Login realizado com sucesso');
    } on FirebaseAuthException catch (e, s) {
      _log.error('Erro ao fazer login no Firebase Auth', e, s);
      throw Failure('Erro ao fazer login no Firebase');
    }
  }

  Future<void> _getUserData() async {
    final userLogged = await _userRepository.getUserLogged();
    await _localStorage.write<String>(
        Constants.USER_DATA_KEY, userLogged.toJson());
  }

  Future<void> _saveAccessToken(String accessToken) =>
      _localStorage.write<String>(Constants.ACCESS_TOKEN_KEY, accessToken);

  Future<void> _confirmLogin() async {
    final confirmModel = await _userRepository.confirmLogin();
    await _saveAccessToken(confirmModel.accessToken);
    await _localSecurityStorage.write(
        Constants.REFRESH_TOKEN_KEY, confirmModel.refreshToken);
  }

  @override
  Future<void> socialLogin(SocialType socialType) async {
    // Declaracoes
    // ignore: unused_local_variable
    String? email;

    try {
      final SocialNetworkModel socialModel;
      final AuthCredential authCredential;
      final firebaseAuth = FirebaseAuth.instance;

      switch (socialType) {
        case SocialType.facebook:
          socialModel = await _socialRepository.facebookLogin();
          authCredential =
              FacebookAuthProvider.credential(socialModel.accessToken);
          break;
        case SocialType.google:
          socialModel = await _socialRepository.googleLogin();
          authCredential = GoogleAuthProvider.credential(
            accessToken: socialModel.accessToken,
            idToken: socialModel.id,
          );
          break;
      }

      final loginMethods =
          await firebaseAuth.fetchSignInMethodsForEmail(socialModel.email);
      final methodCheck = _getMethodToSocialLoginType(socialType);
      if (loginMethods.isNotEmpty && !loginMethods.contains(methodCheck)) {
        throw Failure(
            'Login não pode ser feito por $methodCheck, por favor utilize outro método');
      }
      // Processo comum do login com rede social
      await firebaseAuth.signInWithCredential(authCredential);
      final accessToken = await _userRepository.socialLogin(socialModel);
      await _saveAccessToken(accessToken);
      await _confirmLogin();
      await _getUserData();
    } on FirebaseAuthException catch (e, s) {
      _log.error('Erro ao realizar login com $socialType', e, s);
      throw Failure('Erro ao realizar login no Firebase');
    }
  }

  String _getMethodToSocialLoginType(SocialType socialType) {
    switch (socialType) {
      case SocialType.facebook:
        return 'facebook.com';

      case SocialType.google:
        return 'google.com';
    }
  }
}
