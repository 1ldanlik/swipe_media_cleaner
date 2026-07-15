class AuthGateState {
  final bool isRegisterMode;
  final bool isLoading;
  final String? errorText;

  const AuthGateState({this.isRegisterMode = false, this.isLoading = false, this.errorText});

  AuthGateState copyWith({
    bool? isRegisterMode,
    bool? isLoading,
    String? errorText,
    bool clearErrorText = false,
  }) {
    return AuthGateState(
      isRegisterMode: isRegisterMode ?? this.isRegisterMode,
      isLoading: isLoading ?? this.isLoading,
      errorText: clearErrorText ? null : (errorText ?? this.errorText),
    );
  }
}
