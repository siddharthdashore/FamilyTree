import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/citizen_registration_model.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final RegisteredCitizen? registeredCitizen;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.registeredCitizen,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    RegisteredCitizen? registeredCitizen,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      registeredCitizen: registeredCitizen ?? this.registeredCitizen,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthNotifier(this._apiClient) : super(const AuthState());

  Future<RegisteredCitizen?> registerCitizen(CitizenRegistrationModel model) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiClient.post(
        ApiEndpoints.citizenRegister,
        body: model.toJson(),
      );

      if (response['data'] != null) {
        final citizen = RegisteredCitizen.fromJson(response['data']);
        state = state.copyWith(isLoading: false, registeredCitizen: citizen);
        return citizen;
      }

      state = state.copyWith(isLoading: false, errorMessage: 'Registration response invalid.');
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthNotifier(apiClient);
});
