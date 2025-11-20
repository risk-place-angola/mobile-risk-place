// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safe_place.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SafePlaceAdapter extends TypeAdapter<SafePlace> {
  @override
  final int typeId = 2;

  @override
  SafePlace read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SafePlace(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      category: fields[5] as SafePlaceCategory,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SafePlace obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafePlaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SafePlaceCategoryAdapter extends TypeAdapter<SafePlaceCategory> {
  @override
  final int typeId = 3;

  @override
  SafePlaceCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SafePlaceCategory.home;
      case 1:
        return SafePlaceCategory.work;
      case 2:
        return SafePlaceCategory.policeStation;
      case 3:
        return SafePlaceCategory.hospital;
      case 4:
        return SafePlaceCategory.fireStation;
      case 5:
        return SafePlaceCategory.family;
      case 6:
        return SafePlaceCategory.friend;
      case 7:
        return SafePlaceCategory.other;
      default:
        return SafePlaceCategory.home;
    }
  }

  @override
  void write(BinaryWriter writer, SafePlaceCategory obj) {
    switch (obj) {
      case SafePlaceCategory.home:
        writer.writeByte(0);
        break;
      case SafePlaceCategory.work:
        writer.writeByte(1);
        break;
      case SafePlaceCategory.policeStation:
        writer.writeByte(2);
        break;
      case SafePlaceCategory.hospital:
        writer.writeByte(3);
        break;
      case SafePlaceCategory.fireStation:
        writer.writeByte(4);
        break;
      case SafePlaceCategory.family:
        writer.writeByte(5);
        break;
      case SafePlaceCategory.friend:
        writer.writeByte(6);
        break;
      case SafePlaceCategory.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafePlaceCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
