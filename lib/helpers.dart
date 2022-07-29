import 'package:string_similarity/string_similarity.dart';
import 'package:function_tree/function_tree.dart';

List operators = ["+", "-", "*", "/", "%", "**", "//"];

// Check if given value is float
bool check_float(String value) {
  if (!value.contains(".")) {
    return false;
  }

  try {
    double.parse(value);
    return true;
  } catch (e) {
    return false;
  }
}

// Checks the qoutations type of a string
String check_string_qoutation(String text) {
  // Triple quotation ("""hello""")
  if (text.startsWith('"""') && text.endsWith('"""')) {
    return "Triple";
  }

  // Double quotation ("hello")
  if (text.startsWith('"') && text.endsWith('"')) {
    return "Double";
  }

  // Single quotation ('hello')
  if (text.startsWith("'") && text.endsWith("'")) {
    return "Single";
  }

  return "Confused";
}

// Type checker
String check_type(String target) {
  List qoutations = ["'", '"', '"""'];
  List booleans = ["True", "False"];

  // Checking if digit
  if (RegExp(r'^[0-9]+$').hasMatch(target)) {
    return "Integer";
  }

  // Checking if string
  if (target[0] == target[target.length - 1] &&
      qoutations.contains(target[0])) {
    return "String";
  }

  // Checking if boolean
  if (booleans.contains(target)) {
    return "Boolean";
  }

  // Checking if float
  if (RegExp(r'^(?:-?(?:[0-9]+))?(?:\.[0-9]*)?(?:[eE][\+\-]?(?:[0-9]+))?$')
      .hasMatch(target)) {
    return "Float";
  }

  // Checking if list
  if (target[0] == "[" && target[target.length - 1] == "]") {
    return "List";
  }

  // Checking if dict
  if (target == "{}" ||
      target[0] == "{" &&
          target[target.length - 1] == "}" &&
          target.contains(":") &&
          target.split(":").length >= 2) {
    return "Dict";
  }

  // Checking if operations
  for (var char in operators) {
    if (target.contains(char)) {
      return "Operation";
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
      return "zero";
    }
  } catch (e) {
    return "invalid";
  }
}

// Check similarity between 2 strings
double similar(String a, String b) {
  var result = StringSimilarity.compareTwoStrings(a, b);
  return result;
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

// Extracts items from string
List string_vars_extractor(text) {
  RegExp exp = RegExp(r"\{(.+?)\}");
  List final_list = [];

  for (var i in exp.allMatches(text)) {
    if (text.substring(i.start, i.end).trim() == "") {
      continue;
    }
    final_list.add(text.substring(i.start + 1, i.end - 1));
  }
  return final_list;
}
