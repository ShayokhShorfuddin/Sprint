import 'utilities.dart';
import 'package:function_tree/function_tree.dart';
import 'package:string_similarity/string_similarity.dart';

List operators = ["+", "-", "*", "/", "%", "**", "//"];

////// Helpers start from here ////////
///// Each helper does something small but useful. ///////

// String quotation remover (Removes the quotations from texts and returns the raw text for us to use)
String remove_quotation(text) {
  // Checking the type of quotation
  String string_type = check_string_type(text);

  // Triple quotation ("""hello""")
  if (string_type == "Triple") {
    return text.substring(3, text.length - 3);
  }

  // Double quotation ("hello")
  if (string_type == "Double") {
    return text.substring(1, text.length - 1);
  }

  // Single quotation ('hello')
  if (string_type == "Single") {
    return text.substring(1, text.length - 1);
  }

  // If the string is invalid, we will just return "Invalid"
  return "Invalid";
}

// String Type Checker (Determines the type of string based on the quotations)
String check_string_type(String text) {
  // Triple quotation ("""hello""")      # the len(text) is to make sure the given text is at least """""" or "" or ''
  if (len(text) >= 6 && text.startsWith('"""') && text.endsWith('"""')) {
    return "Triple";
  }

  // Double quotation ("hello")
  if (len(text) >= 2 && text.startsWith('"') && text.endsWith('"')) {
    return "Double";
  }

  // Single quotation ('hello')
  if (len(text) >= 2 && text.startsWith("'") && text.endsWith("'")) {
    return "Single";
  }

  // If its not a valid string, we will just return "Invalid"
  return "Invalid";
}

// Check if given value is float
bool check_float(String value) {
  if (value.contains(".") == false) {
    return false;
  }

  try {
    double.parse(value);
    return true;
  } catch (e) {
    return false;
  }
}

// Item Extractor (Extracts items from string. "Items" are basically the {something} given in strings for String Interpolation.)
List string_items_extractor(text) {
  RegExp exp = RegExp(r"\{(.+?)\}");
  List final_list = [];

  // Removing empty items. Example -> (['  pizza  ', '  bicycle   ', '    '])
  for (var i in exp.allMatches(text)) {
    if (text.substring(i.start, i.end).trim() == "") {
      continue;
    }
    final_list.add(text.substring(i.start + 1, i.end - 1));
  }
  return final_list;
}

// Similarity checker (Used for variable_suggestor to check if an not-defined variable is close to any existing variable)
double similar(String a, String b) {
  double result = StringSimilarity.compareTwoStrings(a, b);
  return result;
}

// Variable name validator (Basically checks if a variable name given by the coder is valid or not)
String variable_name_validator(String name) {
  // These are all the conditions to detect invalid names. If name bypasses all conditions, we can assume its a valid name.

  // 1. Cannot contain a dot (.)
  if (name.contains(".")) {
    return "Invalid";
  }

  // 2. Cannot contain -
  if (name.contains("-")) {
    return "Invalid";
  }

  // 3. Cannot contain space (" ")
  if (name.contains(" ")) {
    return "Invalid";
  }

  // 4. Cannot start with a number (0-9)
  if (RegExp(r'^[0-9]+$').hasMatch(name[0])) {
    return "Invalid";
  }

  // Assuming its a valid name
  return "Valid";
}

// Variable Suggestor (Suggests possible existing variables to the coder. Example: "Did you mean weather?". The coder did - "print weathar")

dynamic variable_suggestor(last_value, runtime_variables) {
  List possible_matches = [];

  for (var i in runtime_variables.keys) {
    if (similar(last_value, i) >= 0.6) {
      possible_matches.add(i);
    }
  }

  // Suggestions available
  if (possible_matches.isNotEmpty) {
    var suggestions_text = "Did you mean ${possible_matches.join(" or ")}?";
    return suggestions_text;
  }

  // No suggestions available
  if (possible_matches.isEmpty) {
    return null;
  }
}

// Type checker (Check type of stuffs)
String check_type(String target) {
  List booleans = ["True", "False"];

  target = target.toString();

  // Checking if digit
  if (RegExp(r'^[0-9]+$').hasMatch(target)) {
    return "Integer";
  }
  // Using check_string_type(target) != "Invalid" because check_string_type(target) will always return Invalid if given string is not valid. So we can assue if the output is not Invalid, its definately a String
  if (check_string_type(target) != "Invalid") {
    return "String";
  }

  // Checking if boolean
  if (booleans.contains(target)) {
    return "Boolean";
  }

  // Checking if float
  if (check_float(target)) {
    return "Float";
  }

  // Checking if it's a math
  for (var symbol in operators) {
    if (target.contains(symbol)) {
      return "Math";
    }
  }

  // Returning "Variable" as no types match
  return "Variable";
}

// Perform math
dynamic perform_math(String equation) {
  try {
    var result = equation.interpret();

    if (result != double.infinity) {
      return result;
    }

    if (result == double.infinity) {
      return "Zero";
    }
  } catch (e) {
    return "Invalid";
  }
}

// Custom split function
List customsplit(String string, String separator, {int max = 0}) {
  var result = [];

  if (separator.isEmpty) {
    result.add(string);
    return result;
  }

  while (true) {
    var index = string.indexOf(separator, 0);
    if (index == -1 || (max > 0 && result.length >= max)) {
      result.add(string);
      break;
    }

    result.add(string.substring(0, index));
    string = string.substring(index + separator.length);
  }

  return result;
}
