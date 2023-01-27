// To parse this JSON data, do
//
//     final notes = notesFromJson(jsonString);

import 'dart:convert';

Notes notesFromJson(String str) => Notes.fromJson(json.decode(str));

String notesToJson(Notes data) => json.encode(data.toJson());

class Notes {
  Notes({
    this.page,
    this.perPage,
    this.totalPages,
    this.totalItems,
    this.items,
  });

  int? page;
  int? perPage;
  int? totalPages;
  int? totalItems;
  List<Item>? items;

  factory Notes.fromJson(Map<String, dynamic> json) => Notes(
        page: json["page"],
        perPage: json["perPage"],
        totalPages: json["totalPages"],
        totalItems: json["totalItems"],
        items: json["items"] == null
            ? null
            : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "perPage": perPage,
        "totalPages": totalPages,
        "totalItems": totalItems,
        "items": items == null
            ? null
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class Item {
  Item({
    this.id,
    this.collectionId,
    this.collectionName,
    this.created,
    this.updated,
    this.note,
    this.userId,
  });

  String? id;
  String? collectionId;
  String? collectionName;
  DateTime? created;
  DateTime? updated;
  String? note;
  String? userId;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created:
            json["created"] == null ? null : DateTime.parse(json["created"]),
        updated:
            json["updated"] == null ? null : DateTime.parse(json["updated"]),
        note: json["note"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created == null ? null : created!.toIso8601String(),
        "updated": updated == null ? null : updated!.toIso8601String(),
        "note": note,
        "user_id": userId,
      };
}
