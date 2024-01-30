import 'package:droit_app/models/firebase_functions.dart';
import 'package:droit_app/screens/chat_screen.dart';
import 'package:droit_app/models/realm_functions.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {

  List<String> allUserList = [];
  List<String> filteredList = [];

  @override
  void initState() {
    super.initState();
    // Fetching the data from firestore
    userRef.get().then((value) => setState(() {
        for (int i = 0; i < value.docs.length; i++) {
          allUserList.add(value.docs[i].data().email);
        }
        filteredList = allUserList;
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
      return SearchBar(
        surfaceTintColor: MaterialStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        controller: controller..addListener(() { filterLogListBySearchText(controller.text);}),
        padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        onTap: () {
          controller.openView();
        },
        onChanged: (text) {
          controller.openView();
        },
        leading: const Icon(Icons.search),
        hintText: "Tap the user's email",
      );
    }, suggestionsBuilder: (BuildContext context, SearchController controller) {
      return List<ListTile>.generate(filteredList.length, (int index) {
        return ListTile(
          title: Text(filteredList[index]),
          onTap: () {
            String friend = filteredList[index];
            controller.closeView(friend);
            setState(() {
              currentFriendToRealm(
                friend);
              Future.delayed(
                  const Duration(milliseconds: 50), () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const ChatScreen()));
              });
            });
          },
        );
      });
    });
  }

  void filterLogListBySearchText(String searchText) {
    setState(() {
      filteredList = allUserList
          .where((logObj) =>
              logObj.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

}
