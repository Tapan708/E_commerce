import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saturday_practise/Custom_Widgets/bottom_model.dart';
import 'package:saturday_practise/Custom_Widgets/custom_textfiled.dart';

class AdminAddProduct extends StatefulWidget {
  final bool? isEdit;
  final QueryDocumentSnapshot? productDetail;
  const AdminAddProduct({Key? key, this.isEdit = false,this.productDetail}) : super(key: key);

  @override
  State<AdminAddProduct> createState() => _AdminAddProductState();
}

class _AdminAddProductState extends State<AdminAddProduct> {
  TextEditingController product_name = TextEditingController();
  TextEditingController product_description = TextEditingController();
  TextEditingController product_price = TextEditingController();
  TextEditingController additional_images = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  final _formkey = GlobalKey<FormState>();
  File? image;
  bool switchs = false;
  List<File?> additionalImagesList = [];

  @override
  void initState() {
    //log("value : ${widget.isEdit}");
    if(widget.isEdit ==true){
      product_name.text = widget.productDetail!['product_name'];
      product_description.text = widget.productDetail!['product_description'];
      product_price.text = widget.productDetail!['product_price'];
      switchs = widget.productDetail!['is_available'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text(widget.isEdit == true ?'Update Product Here'
            : 'Add Product Here'),
      ),
      body:
      ListView(
        children: [
          Form(
            key: _formkey,
            child: Column(
              children: [
                InkWell(
                  onTap: show_bottom_model_sheet,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      radius: 80,
                      backgroundImage: image != null ? FileImage(image!) : null,
                      child: image != null
                          ? null
                          : Icon(Icons.add_a_photo, color: Colors.black, size: 40),
                    ),
                  ),
                ),
                SizedBox(height: 6),
                CustomTextField(
                  labeltext: 'Enter Product Name',
                  controller: product_name,
                  textInputType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Product Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 6),
                CustomTextField(
                  maxlines: 6,
                  labeltext: 'Enter Product Description',
                  controller: product_description,
                  textInputType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Product Description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 6),
                CustomTextField(
                  prefixicon: Icon(Icons.currency_rupee),
                  labeltext: 'Enter Product Price',
                  controller: product_price,
                  textInputType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Product Price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 6),
                CustomTextField(
                  suffixicon: IconButton(
                    onPressed: () => give_image_add_option(),
                    icon: Icon(Icons.arrow_circle_right_rounded),
                  ),
                  labeltext: 'Number of additional images',
                  controller: additional_images,
                  textInputType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter the number of additional images';
                    } else if (int.parse(value) > 5) {
                      return 'You can add a maximum of 5 images';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 6),
                ...additionalImagesList
                    .asMap()
                    .entries
                    .map((entry) => GestureDetector(
                  onTap: () => select_additional_image(entry.key),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                    height: 200,
                    width: double.infinity,
                    color: Colors.black12,
                    child: entry.value != null
                        ? Image.file(
                      entry.value!,
                      fit: BoxFit.cover,
                    )
                        : Center(
                      child: Text('Add Image', style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                ))
                    .toList(),
                ListTile(
                  leading: Text(
                    'Is Product Available?',
                    style: TextStyle(fontSize: 17),
                  ),
                  trailing: Switch(
                    value: switchs,
                    onChanged: (value) {
                      setState(() {
                        switchs = value;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: add_product,
                  child: Text('Add Product'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> show_bottom_model_sheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BootomModelSheet(onPressedGallery: gallery_image, onPressedCamera: camera_image);
      },
    );
  }

  Future<void> gallery_image() async {
    Navigator.pop(context); // Close the bottom sheet
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> camera_image() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> add_product() async {
    if (_formkey.currentState!.validate()) {
      if (additionalImagesList.contains(null)) {
        Fluttertoast.showToast(
          msg: 'Please select all additional images',
          fontSize: 17,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }

      try {
        String imageUrl = await uploadImage(image!);
        List<String> additionalImagesUrls = await uploadAdditionalImages();

        await _firestore.collection('products').add({
          'product_name': product_name.text,
          'product_description': product_description.text,
          'product_price': product_price.text,
          'image': imageUrl,
          'additional_images': additionalImagesUrls,
          'is_available': switchs,
        });

        product_name.clear();
        product_description.clear();
        product_price.clear();
        additional_images.clear();
        setState(() {
          image = null;
          switchs = false;
          additionalImagesList.clear();
        });

        Fluttertoast.showToast(
          msg: 'Product Added Successfully',
          fontSize: 17,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG,
        );
      } catch (error) {
        Fluttertoast.showToast(
          msg: 'Failed to add product: $error',
          fontSize: 17,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    }
  }

  Future<String> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = _storage.ref().child('images/$fileName.jpeg');
      UploadTask uploadTask = reference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (error) {
      throw error;
    }
  }

  Future<List<String>> uploadAdditionalImages() async {
    List<String> urls = [];
    for (File? file in additionalImagesList) {
      if (file != null) {
        try {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference reference = _storage.ref().child('images/$fileName.jpeg');
          UploadTask uploadTask = reference.putFile(file);
          TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
          String imageUrl = await taskSnapshot.ref.getDownloadURL();
          urls.add(imageUrl);
        } catch (error) {
          throw error;
        }
      }
    }
    return urls;
  }

  void give_image_add_option() {
    int count = int.tryParse(additional_images.text) ?? 0;
    if (count > 5) {
      Fluttertoast.showToast(
        msg: 'You can add a maximum of 5 images',
        fontSize: 17,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
    } else {
      setState(() {
        if (count > additionalImagesList.length) {
          additionalImagesList.addAll(List<File?>.filled(count - additionalImagesList.length, null));
        } else if (count < additionalImagesList.length) {
          additionalImagesList = additionalImagesList.sublist(0, count);
        }
      });
    }
  }

  Future<void> select_additional_image(int index) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        additionalImagesList[index] = File(pickedFile.path);
      });
    }
  }
}







/*
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saturday_practise/Custom_Widgets/custom_textfiled.dart';

class AdminAddProduct extends StatefulWidget {
  const AdminAddProduct({super.key});

  @override
  State<AdminAddProduct> createState() => _AdminAddProductState();
}

class _AdminAddProductState extends State<AdminAddProduct> {
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController price = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  File? _avatarImage;
  List<File> _additionalImages = [];
  bool _avatarImageSelected = true;
  bool _additionalImagesSelected = true;
  bool _isAvailable = true; // Variable to track product availability

  Future<void> _getAvatarImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _avatarImage = File(image.path);
                    _avatarImageSelected = true; // Reset error state
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImagePicker().pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    _avatarImage = File(image.path);
                    _avatarImageSelected = true; // Reset error state
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getAdditionalImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _additionalImages = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
        _additionalImagesSelected = true; // Reset error state
      });
    }
  }

  Future<void> addproduct() async {
    if (_formkey.currentState!.validate() && _avatarImage != null) {
      final _firestore = FirebaseFirestore.instance;
      final _storage = FirebaseStorage.instance;
      String avatarImageUrl;
      List<String> additionalImageUrls = [];

      try {
        // Upload the avatar image
        String avatarFileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference avatarStorageReference = _storage.ref().child('product_images/$avatarFileName.jpeg');
        UploadTask avatarUploadTask = avatarStorageReference.putFile(_avatarImage!);
        TaskSnapshot avatarTaskSnapshot = await avatarUploadTask.whenComplete(() {});
        avatarImageUrl = await avatarTaskSnapshot.ref.getDownloadURL();

        for (var image in _additionalImages) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageReference = _storage.ref().child('product_images/$fileName.jpeg');
          UploadTask uploadTask = storageReference.putFile(image);
          TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          String imageUrl = await taskSnapshot.ref.getDownloadURL();
          additionalImageUrls.add(imageUrl);
        }

        print('Images uploaded. Avatar URL: $avatarImageUrl, Additional URLs: $additionalImageUrls');

        print('Adding product to Firestore...');
        await _firestore.collection('products').doc().set({
          'product_name': name.text.trim(),
          'product_description': description.text.trim(),
          'price': price.text.trim(),
          'avatar_image': avatarImageUrl,
          'additional_images': additionalImageUrls,
          'is_available': _isAvailable, // Save product availability status
        });

        print('Product added successfully.');

        name.clear();
        description.clear();
        price.clear();
        setState(() {
          _avatarImage = null;
          _additionalImages = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully')),
        );
      } catch (e) {
        print('Error adding product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else if (_avatarImage == null) {
      setState(() {
        _avatarImageSelected = false; // Set error state
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an avatar image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Products'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          InkWell(
            onTap: _getAvatarImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _avatarImage != null
                  ? FileImage(_avatarImage!)
                  : null,
              backgroundColor: Colors.grey[200],
              child: _avatarImage == null
                  ? Icon(
                Icons.add_a_photo,
                color: _avatarImageSelected ? Colors.grey[800] : Colors.red,
                size: 50,
              )
                  : null,
            ),
          ),
          SizedBox(height: 16),
          Form(
            key: _formkey,
            child: Column(
              children: [
                CustomTextField(
                  labeltext: 'Enter Product Name',
                  controller: name,
                  textInputType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Name';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  labeltext: 'Enter Product Description',
                  controller: description,
                  maxlines: 6,
                  textInputType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Description';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  labeltext: 'Enter Product Price',
                  controller: price,
                  icon: Icon(Icons.currency_rupee),
                  textInputType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Price';
                    }
                    return null;
                  },
                ),
                SwitchListTile(
                  title: Text('Is Product Available?'),
                  value: _isAvailable,
                  onChanged: (bool value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: _getAdditionalImages,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: _additionalImages.isNotEmpty
                    ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _additionalImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(
                        _additionalImages[index],
                        height: 210,
                        width: 310,
                        fit: BoxFit.fill,
                      ),
                    );
                  },
                )
                    : Text(
                  'Please select up to 5 images',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(onPressed: addproduct, child: Text('Add Product')),
        ],
      ),
    );
  }
}
*/
