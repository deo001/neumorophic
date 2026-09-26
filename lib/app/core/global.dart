 void getInitialLetters (String? name) {

    if (name != null && name.isNotEmpty) {
      List<String> words = name.split(' ');
      String initials = '';
      for (var word in words) {
        if (word.isNotEmpty) {
          initials += word[0].toUpperCase();
        }
      }
      print(initials); // Output the initials
    } else {
      print('Name is empty or null');
    }
    
  }


 