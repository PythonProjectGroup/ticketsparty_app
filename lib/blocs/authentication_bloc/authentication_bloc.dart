import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticketspartyapp/utils/user_repository.dart';
import 'package:tuple/tuple.dart';

import './bloc.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event,
      ) async* {
    if (event is AppStarted) {
      try {
        final String token = await UserRepository.getTokenAndVerify();
        if (token != null) {
          yield AuthenticationAuthenticated(authToken: token);
        } else {
          yield AuthenticationUnauthenticated();
        }
      } catch (error) {
        print(error);

        yield AuthenticationNotPossible();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await UserRepository.persistTokenAndRefresh(
          Tuple2(event.refresh, event.token));
      yield AuthenticationAuthenticated(authToken: event.token);
    }
    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await UserRepository.deleteToken();
      yield AuthenticationUnauthenticated();
    }
    if (event is TokenRenewed) {
      yield new AuthenticationAuthenticated(authToken: event.token);
    }
    if (event is LostAuthentication) {
      yield AuthenticationUnauthenticated();
    }
    if (event is AuthenticationError) {
      yield AuthenticationNotPossible();
    }
  }
}
