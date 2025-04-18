import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchAddresses();
    });
  }

  Future<void> _showAddEditAddressDialog([String? existingAddress, int? index]) async {
    final addressController = TextEditingController(text: existingAddress ?? '');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingAddress == null ? 'Add New Address' : 'Edit Address'),
        content: TextField(
          controller: addressController,
          decoration: InputDecoration(labelText: 'Address'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (addressController.text.trim().isEmpty) {
                return;
              }

              if (existingAddress == null) {
                await context.read<UserProvider>().addAddress(addressController.text);
              } else {
                await context.read<UserProvider>().updateAddress(index!, addressController.text);
              }

              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Addresses'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (userProvider.addresses.isEmpty) {
            return Center(
              child: Text('No saved addresses found'),
            );
          }

          return ListView.builder(
            itemCount: userProvider.addresses.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final address = userProvider.addresses[index];
              return Card(
                child: ListTile(
                  title: Text(address),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showAddEditAddressDialog(address, index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Address'),
                              content: Text('Are you sure you want to delete this address?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await userProvider.deleteAddress(index);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditAddressDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}