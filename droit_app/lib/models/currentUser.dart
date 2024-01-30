import 'package:realm/realm.dart'; // import realm package

part 'currentUser.g.dart'; // declare a part file.

@RealmModel()
class _CurrentUser {
  late String email;
  late String type; // either "host" or "friend"
}
