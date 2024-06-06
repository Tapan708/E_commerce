import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class UserProductDetails extends StatefulWidget {
  final QueryDocumentSnapshot document;
  const UserProductDetails({super.key,required this.document});

  @override
  State<UserProductDetails> createState() => _UserProductDetailsState();
}

class _UserProductDetailsState extends State<UserProductDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text(widget.document['product_name']),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.hasData){
            final product = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(height: 300,child: Image.network(widget.document['image']))
                ],
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}



/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProductDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot product;

  UserProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['product_name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(product['avatar_image']),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            SizedBox(height: 16),
            Text(
              product['product_name'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              product['product_description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '₹${product['price']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 16),
            product['additional_images'] != null && product['additional_images'].isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Images:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: product['additional_images'].length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.network(
                          product['additional_images'][index],
                          height: 200,
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
*/
