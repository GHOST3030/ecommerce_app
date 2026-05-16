import 'package:ecommerce_app/core/supabase/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => SupabaseService.client,
);

final supabaseAuthProvider = Provider<GoTrueClient>(
  (_) => SupabaseService.auth,
);

final supabaseStorageProvider = Provider<SupabaseStorageClient>(
  (_) => SupabaseService.storage,
);