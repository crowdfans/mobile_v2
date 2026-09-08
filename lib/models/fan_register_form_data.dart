/// Dados do cadastro Superfã (espelho de `fan-register-form-data.ts`).
class FanRegisterFormData {
  const FanRegisterFormData({
    this.phoneCountryCode = '+55',
    this.phone = '',
    this.phoneVerified = false,
    this.firebaseUid = '',
    this.name = '',
    this.username = '',
    this.avatarUri = '',
    this.description = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.birthDay = 1,
    this.birthMonth = 1,
    this.birthYear = 1990,
  });

  final String phoneCountryCode;
  final String phone;
  final bool phoneVerified;
  final String firebaseUid;
  final String name;
  final String username;
  final String avatarUri;
  final String description;
  final String email;
  final String password;
  final String confirmPassword;
  final int birthDay;
  final int birthMonth;
  final int birthYear;

  DateTime get birthdate => DateTime(birthYear, birthMonth, birthDay);

  FanRegisterFormData copyWith({
    String? phoneCountryCode,
    String? phone,
    bool? phoneVerified,
    String? firebaseUid,
    String? name,
    String? username,
    String? avatarUri,
    String? description,
    String? email,
    String? password,
    String? confirmPassword,
    int? birthDay,
    int? birthMonth,
    int? birthYear,
  }) {
    return FanRegisterFormData(
      phoneCountryCode: phoneCountryCode ?? this.phoneCountryCode,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUri: avatarUri ?? this.avatarUri,
      description: description ?? this.description,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      birthDay: birthDay ?? this.birthDay,
      birthMonth: birthMonth ?? this.birthMonth,
      birthYear: birthYear ?? this.birthYear,
    );
  }
}
