// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currentUser.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class CurrentUser extends _CurrentUser
    with RealmEntity, RealmObjectBase, RealmObject {
  CurrentUser(
    String email,
    String type,
  ) {
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'type', type);
  }

  CurrentUser._();

  @override
  String get email => RealmObjectBase.get<String>(this, 'email') as String;
  @override
  set email(String value) => RealmObjectBase.set(this, 'email', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  Stream<RealmObjectChanges<CurrentUser>> get changes =>
      RealmObjectBase.getChanges<CurrentUser>(this);

  @override
  CurrentUser freeze() => RealmObjectBase.freezeObject<CurrentUser>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CurrentUser._);
    return const SchemaObject(
        ObjectType.realmObject, CurrentUser, 'CurrentUser', [
      SchemaProperty('email', RealmPropertyType.string),
      SchemaProperty('type', RealmPropertyType.string),
    ]);
  }
}
