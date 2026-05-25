# Auth — Logic Layer (Contract + Entity + State + Notifier + Provider)

#: 13
Assigned: Ahmed Alalawi
Depends on: Auth — Data Layer (Datasource + Model + Mapper + Repo Impl) (Auth%20%E2%80%94%20Data%20Layer%20(Datasource%20+%20Model%20+%20Mapper%20+%20R%20618b726e2ca0468bb37b6d1ffd47fb7a.md), Setup Supabase Connection (Setup%20Supabase%20Connection%205a2f8c2ad7dc43a0b1f33654596c0f60.md)
Description: auth/logic/contracts/auth_repository.dart (abstract IAuthRepository). auth/logic/entities/user_entity.dart. auth/logic/states/auth_state.dart (sealed: initial, loading, authenticated, unauthenticated, error). auth/logic/notifiers/auth_notifier.dart (AsyncNotifier: signIn, signUp, signOut). auth/logic/providers/auth_provider.dart (authNotifierProvider, currentUserProvider, authStateProvider).
Stage: 3. Auth Feature
Status: Done