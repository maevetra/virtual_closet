import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_closet/service/database.dart';

class Clothing {
  static Random random = Random();

  String? uid;
  String? path;
  String? filename;
  String? link;
  String category;
  String sleeves;
  String color;
  String materials;

  Clothing(this.uid, this.path, this.category, this.sleeves, this.color, this.materials);

  Clothing.usingLink(this.uid, this.filename, this.link, this.category, this.sleeves, this.color, this.materials);

  Clothing.full(this.uid, this.path, this.filename, this.link, this.category, this.sleeves, this.color, this.materials);

  Clothing.clone(Clothing other) : this.full(other.uid, other.path, other.filename, other.link, other.category, other.sleeves, other.color, other.materials);

  @override
  bool operator==(Object other) =>
    identical(this, other) || (
      other is Clothing &&
      uid == other.uid &&
      path == other.path &&
      filename == other.filename &&
      link == other.link &&
      category == other.category &&
      sleeves == other.sleeves &&
      color == other.color &&
      materials == other.materials
    );

  @override
  int get hashCode => uid.hashCode ^ path.hashCode ^ filename.hashCode ^
    link.hashCode ^ category.hashCode ^ sleeves.hashCode ^ color.hashCode ^
    materials.hashCode;

/*
  Future<List<Clothing>> download() async {
    List<Clothing> result = <Clothing>[];
    await FirebaseStorage.instance.ref().child('clothes/$uid/').listAll().then((res) async {
      for (var ref in res.items) {
        await ref.getDownloadURL().then((link) async {
          await ref.getMetadata().then((metadata) => {
            result.add(Clothing(uid,
              link,
              metadata.customMetadata!['category']!,
              metadata.customMetadata!['sleeves']!,
              metadata.customMetadata!['color']!,
              metadata.customMetadata!['materials']!,
            ))
          });
        });
      }
    });
    return result;
  }*/

  Future<void> upload() async {
    // Create your custom metadata.
    SettableMetadata metadata = SettableMetadata(
      customMetadata: <String, String>{
        'category': category,
        'sleeves': sleeves,
        'color': color,
        'materials': materials,
      },
    );

    try {
      UploadTask task;
      if (filename != null) {
        String newFilename = random.nextInt(4294967296).toString();
        task = FirebaseStorage.instance.ref('clothes/$uid/$newFilename').putData(
          (await FirebaseStorage.instance.ref('clothes/$uid/$filename').getData())!,
          metadata,
        );
        FirebaseStorage.instance.ref('clothes/$uid/$filename').delete();
        filename = newFilename;
      } else {
        File image = File(path!);
        filename = random.nextInt(4294967296).toString();
        task = FirebaseStorage.instance.ref('clothes/$uid/$filename').putFile(image, metadata);
      }
      (await task).ref.getDownloadURL().then((link) => {
        this.link = link
      });
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print('If this ever gets printed, complain to Oleg.');
    }
  }
}
