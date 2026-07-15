class AuthGateStrings {
  static const title = 'Вход в аккаунт';
  static const subtitle = 'Авторизуйтесь, чтобы открыть весь функционал приложения.';

  static const loginTab = 'Вход';
  static const registerTab = 'Регистрация';

  static const emailLabel = 'Email';
  static const passwordLabel = 'Пароль';

  static const createAccountButton = 'Создать аккаунт';
  static const signInButton = 'Войти';

  static const invalidEmail = 'Введите корректный email.';
  static const shortPassword = 'Пароль должен быть не менее 6 символов.';
  static const authFailed = 'Не удалось выполнить авторизацию. Попробуйте снова.';

  static const invalidEmailFirebase = 'Некорректный email.';
  static const emailAlreadyInUse = 'Этот email уже зарегистрирован.';
  static const userNotFound = 'Пользователь не найден.';
  static const invalidCredentials = 'Неверный email или пароль.';
  static const weakPassword = 'Слишком простой пароль.';
  static const networkRequestFailed = 'Проблема с сетью. Проверьте подключение.';
  static const configurationNotFound =
      'Firebase Auth не настроен для этого проекта. Включите Email/Password в Firebase Console.';

  static String unknownFirebaseError(String code, String? message) {
    return message ?? 'Ошибка авторизации. Код: $code';
  }
}
