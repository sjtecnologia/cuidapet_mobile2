import 'package:cuidapet_mobile/app/models/user_model.dart';
import 'package:mobx/mobx.dart';
part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  @observable
  UserModel? userModel;

  @action
  Future<void> loadUser() async {
    userModel = UserModel.empty();
  }
}
