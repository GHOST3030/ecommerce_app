import 'package:ecommerce_app/core/supabase/supabase_provider.dart';
import 'package:ecommerce_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:ecommerce_app/features/auth/data/repositoryimp/auth_repository_impl.dart';
import 'package:ecommerce_app/features/auth/logic/provider/auth_notifier.dart';
import 'package:ecommerce_app/features/auth/logic/repository/auth_repository.dart';
import 'package:ecommerce_app/features/auth/logic/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasource(ref.watch(supabaseClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider)),
);

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);

final authStatusProvider = Provider<AuthStatus>(
  (ref) => ref.watch(authNotifierProvider).status,
);

final currentUserProvider = Provider(
  (ref) => ref.watch(authNotifierProvider).user,
);

final authIsLoadingProvider = Provider<bool>(
  (ref) => ref.watch(authNotifierProvider).isLoading,
);

final authErrorProvider = Provider<String?>(
  (ref) => ref.watch(authNotifierProvider).errorMessage,
);
