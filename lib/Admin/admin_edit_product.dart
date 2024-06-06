


/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saturday_practise/Custom_Widgets/custom_textfiled.dart';

class AdminEditProduct extends StatefulWidget {
  final DocumentSnapshot product;

  const AdminEditProduct({required this.product, super.key});

  @override
  _AdminEditProductState createState() => _AdminEditProductState();
}

class _AdminEditProductState extends State<AdminEditProduct> {
  late TextEditingController name;
  late TextEditingController description;
  late TextEditingController price;
  final _formKey = GlobalKey<FormState>();
  File? _avatarImage;
  List<File> _additionalImages = [];
  bool _avatarImageSelected = true;
  bool _additionalImagesSelected = true;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.product['product_name']);
    description = TextEditingController(text: widget.product['product_description']);
    price = TextEditingController(text: widget.product['price'].toString());
    _isAvailable = widget.product['is_available'];
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    price.dispose();
    super.dispose();
  }

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

  Future<void> editProduct() async {
    if (_formKey.currentState!.validate()) {
      final _firestore = FirebaseFirestore.instance;
      final _storage = FirebaseStorage.instance;
      String? avatarImageUrl = widget.product['avatar_image'];
      List<String> additionalImageUrls = List.from(widget.product['additional_images']);

      try {
        // Upload the new avatar image if it has been changed
        if (_avatarImage != null) {
          String avatarFileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference avatarStorageReference = _storage.ref().child('product_images/$avatarFileName.jpeg');
          UploadTask avatarUploadTask = avatarStorageReference.putFile(_avatarImage!);
          TaskSnapshot avatarTaskSnapshot = await avatarUploadTask.whenComplete(() {});
          avatarImageUrl = await avatarTaskSnapshot.ref.getDownloadURL();
        }

        // Upload additional images if any
        for (var image in _additionalImages) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageReference = _storage.ref().child('product_images/$fileName.jpeg');
          UploadTask uploadTask = storageReference.putFile(image);
          TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          String imageUrl = await taskSnapshot.ref.getDownloadURL();
          additionalImageUrls.add(imageUrl);
        }

        await _firestore.collection('products').doc(widget.product.id).update({
          'product_name': name.text.trim(),
          'product_description': description.text.trim(),
          'price': double.tryParse(price.text.trim()),
          'avatar_image': avatarImageUrl,
          'additional_images': additionalImageUrls,
          'is_available': _isAvailable,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
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
                  : NetworkImage(widget.product['avatar_image']) as ImageProvider,
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
            key: _formKey,
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
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
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
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.product['additional_images'].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.network(
                        widget.product['additional_images'][index],
                        height: 210,
                        width: 310,
                        fit: BoxFit.fill,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(onPressed: editProduct, child: Text('Update Product')),
        ],
      ),
    );
  }
}
*/
