enum Gender {
  male,
  female;

  String get label {
    switch (this) {
      case Gender.male:
        return 'Laki-laki';
      case Gender.female:
        return 'Perempuan';
    }
  }
}

enum Religion {
  islam,
  christian,
  catholic,
  hindu,
  buddhist,
  confucian;

  String get label {
    switch (this) {
      case Religion.islam:
        return 'Islam';
      case Religion.christian:
        return 'Kristen Protestan';
      case Religion.catholic:
        return 'Katolik';
      case Religion.hindu:
        return 'Hindu';
      case Religion.buddhist:
        return 'Buddha';
      case Religion.confucian:
        return 'Konghucu';
    }
  }
}

enum MaritalStatus {
  single,
  married,
  divorced,
  widowed;

  String get label {
    switch (this) {
      case MaritalStatus.single:
        return 'Belum Kawin';
      case MaritalStatus.married:
        return 'Kawin';
      case MaritalStatus.divorced:
        return 'Cerai Hidup';
      case MaritalStatus.widowed:
        return 'Cerai Mati';
    }
  }
}
