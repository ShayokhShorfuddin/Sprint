// ignore_for_file: non_constant_identifier_names
import 'dart:io';
import 'helpers.dart';

List normal_types = ["Integer", "String", "Boolean", "Float", "List", "Dict"];
List special_types = ["Operation", "Variable"];

dynamic import_token_processor(line, argv) async {
  List file_list = [];
  List temp_list = customsplit(line, " ", max: 1)[1].trim().split(
      ","); // ["import", "  file1, file2  "] --> "file1, file2" --> ["file1", "file2"]

  // For situations like this: import , test3  (Output - ['', 'test3'])
  for (var i in temp_list) {
    if (i == "") {
      return "invalid_syntax";
    }
  }

  // Removing extra spaces at the start and end of filenames and adding to file_list
  for (var i in temp_list) {
    i = i.trim();
    file_list.add(i);
  }

  // Checking if all the files in file_list exists in current folder
  for (var target_file in file_list) {
    var data = File("$target_file.sp");

    // File exists
    if (await data.exists()) {}

    // Checking if target_file is the currently executing file
    if ("$target_file.sp" == argv[0]) {
      return "import_error:$target_file"; // Sending the name of the file with the string
    }

    // File doesn't exist in current folder
    if (await data.exists() == false) {
      return "file_doesnt_exist:$target_file"; // Sending the name of the file with the string
    }
  }

  return file_list;
}

dynamic from_token_processor(line, argv) async {
  List target_variables = [];
  List temp_list = line.split("import"); // ["from file1", "a, b"]

  var target_file = temp_list[0].split(" ")[1].trim(); // file1
  List temp_variables_list = temp_list[1].split(","); // ["a", "b"]

  // For situations like this: from file1 import , a (Output - ['', 'a'])
  for (var i in temp_variables_list) {
    if (i.trim() == "") {
      return "invalid_syntax";
    }
  }

  // Removing extra spaces at the start and end of variables and adding to target_variables
  for (var i in temp_variables_list) {
    i = i.trim();
    target_variables.add(i);
  }

  // Checking if target_file exists in current folder
  var data = File("$target_file.sp");

  // File exists
  if (await data.exists()) {}

  // Checking if target_file is the currently executing file
  if ("$target_file.sp" == argv[0]) {
    return "import_error:$target_file"; // Sending the name of the file with the string
  }

  // File doesn't exist in current folder
  if (await data.exists() == false) {
    return "file_doesnt_exist:$target_file"; // Sending the name of the file with the string
  }

  target_variables.insert(0, target_file);

  var files_and_vars =
      target_variables; // target_variables contains the filename in position 0

  return files_and_vars;
}

dynamic print_processor(last_type, last_value, Map runtime_variables) {
  if (last_type == "String") {
    List string_formatters = string_vars_extractor(last_value);
    // [' "me" ', '  you ', '2 + 2']
    for (var item in string_formatters) {
      String trimmed_item = item.trim(); // "me"
      // Checking the type of the item
      var item_type = check_type(trimmed_item);
      // Normal types
      if (normal_types.contains(item_type)) {
        if (item_type == "String") {
          // Checking quotation type of the string
          var quote_type = check_string_qoutation(trimmed_item);

          // 'me' or "me"
          if (quote_type == "Single" || quote_type == "Double") {
            last_value = last_value.replaceAll("{" + item + "}",
                trimmed_item.substring(1, trimmed_item.length - 1));
            continue;
          }

          // """me"""
          if (quote_type == "Triple") {
            last_value = last_value.replaceAll("{" + item + "}",
                trimmed_item.substring(3, trimmed_item.length - 3));
            continue;
          }

          // Error
          if (quote_type == "Confused") {
            return "invalid_syntax";
          }
        }

        last_value = last_value.replaceAll("{" + item + "}", "$trimmed_item");
      }

      // Special types
      if (special_types.contains(item_type)) {
        // Variable
        if (item_type == "Variable") {
          // Checking if the vars exists

          // var exists
          if (runtime_variables.keys.contains(trimmed_item)) {
            var stored_value = runtime_variables[trimmed_item];

            // Checking type
            var var_type = check_type(stored_value);

            // If the item is String
            if (var_type == "String") {
              // Checking quotation type of the string
              var quote_type = check_string_qoutation(stored_value);

              // 'me' or "me"
              if (quote_type == "Single" || quote_type == "Double") {
                last_value = last_value.replaceAll("{" + item + "}",
                    stored_value.substring(1, stored_value.length - 1));
                continue;
              }

              // """me"""
              if (quote_type == "Triple") {
                last_value = last_value.replaceAll("{" + item + "}",
                    stored_value.substring(3, stored_value.length - 3));
                continue;
              }

              // Error
              if (quote_type == "Confused") {
                return "invalid_syntax";
              }
            }

            last_value =
                last_value.replaceAll("{" + item + "}", "$stored_value");
          }

          // var doesn't exist
          if (runtime_variables.keys.contains(trimmed_item) == false) {
            return "variable_not_found:$trimmed_item";
          }
        }

        // Operation
        if (item_type == "Operation") {
          var result = perform_math(trimmed_item);

          // Invalid syntax
          if (result == "invalid") {
            return "invalid_syntax";
          }

          // Division by zero
          if (result == "zero") {
            return "zero_division_error";
          }

          last_value = last_value.replaceAll("{" + item + "}", "$result");
        }
      }
    }
  }

  //  Checking for \n in string
  if (last_type == "String" && last_value.contains("\\n")) {
    // Checking string quotation type
    var quote_type = check_string_qoutation(last_value);

    if (quote_type == "Single" || quote_type == "Double") {
      last_value = last_value
          .substring(1, last_value.length - 1)
          .replaceAll("\\n", "\n");

      // Return the value
      return last_value;
    }
  }

  // Return the value
  return last_value;
}

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
  return null;
}

dynamic var_func_extractor(List tokens, [List? wanted_vars]) {
  Map variables = {};
  Map functions = {};

  // Looping through lines to look for variables and functions
  for (var token in tokens) {
    // First point
    var first = token[0];
    var first_type = first.split(":")[0];
    var first_value = first.split(":")[1];

    // Last point
    var last = token[1];
    var last_value = last.split(":")[1];

    // Variable
    if (first_type == "Var") {
      // Checking the type of last_value
      var value_type = check_type(last_value);

      // Integer
      if (value_type == "Integer") {
        variables[first_value] = int.parse(last_value);
      }

      // String
      if (value_type == "String") {
        variables[first_value] = last_value;
      }

      // Boolean
      if (value_type == "Boolean") {
        variables[first_value] = last_value;
      }

      // Float
      if (value_type == "Float") {
        variables[first_value] = double.parse(last_value);
      }

      // Operation
      if (value_type == "Operation") {
        var result = perform_math(last_value);

        // Invalid syntax
        if (result == "invalid") {
          return "invalid";
        }

        // Division by zero
        if (result == "zero") {
          return "zero";
        }

        variables[first_value] = "$result";
      }

      // Variables
      if (value_type == "Variable") {
        // Checking if last_value exists or not
        if (variables.keys.contains(last_value)) {
          variables[first_value] = variables[last_value];
        }

        if (variables.keys.contains(last_value) == false) {
          return [last_value];
        }
      }
    }
  }

  if (wanted_vars == null) {
    return variables;
  }

  Map final_dict = {};

  for (var i in wanted_vars) {
    // Checking if all the wanted_vars are present or not
    if (variables.keys.contains(i)) {
      final_dict[i] = variables[i];
    }

    // If a var is not found
    if (variables.keys.contains(i) == false) {
      return [i];
    }
  }

  return final_dict;
}

dynamic import_processor(last_value) {
  List file_list = last_value.split(",");

  // Looping through all the files
  for (var target_file in file_list) {
    var data = File("$target_file.sp");
    List file_code_tokens = custom_tokenizer(data);
    var result = var_func_extractor(file_code_tokens);

    if (result == "invalid") {
      return "invalid_syntax";
    }

    if (result == "zero") {
      return "zero_division_error";
    }

    if (result is List) {
      var unknown_variable = result[0];
      return "variable_not_found:$unknown_variable";
    }

    return result;
  }
}

dynamic from_processor(last_value) {
  List temp_list = last_value.split(",");

  // Getting the file name and variables from last_value
  var target_file = temp_list[0];
  temp_list.removeAt(
      0); // Removing the first item of the list because if we remove it, we will get all the variables. The first one was filename
  var target_variables = temp_list;

  var data = File("$target_file.sp");
  List file_code_tokens = custom_tokenizer(data);
  var result = var_func_extractor(file_code_tokens, target_variables);

  if (result == "invalid") {
    return "invalid_syntax";
  }

  if (result == "zero") {
    return "zero_division_error";
  }

  if (result is List) {
    var unknown_variable = result[0];
    return "variable_not_found:$unknown_variable";
  }

  return result;
}

dynamic custom_tokenizer(filecontent) {
  // every lines of code without \n
  var code_lines = filecontent.readAsLinesSync();

  // storage for tokens
  List all_tokens = [];

  for (String line in code_lines) {
    // Variable
    if (line.contains("=") && customsplit(line, "=", max: 1).length == 2) {
      var variable_name = customsplit(line, "=", max: 1)[0].trim();
      var variable_value = customsplit(line, "=", max: 1)[1].trim();

      var target_type = check_type(variable_value);
      all_tokens.add(["Var:$variable_name", "$target_type:$variable_value"]);
    }
  }

  return all_tokens;
}

dynamic string_processor(last_value, Map runtime_variables) {
  List string_formatters = string_vars_extractor(last_value);
  // [' "me" ', '  you ', '2 + 2']
  for (var item in string_formatters) {
    String trimmed_item = item.trim(); // "me"
    // Checking the type of the item
    var item_type = check_type(trimmed_item);

    // Normal types
    if (normal_types.contains(item_type)) {
      // For string item
      // If the item is a String. This is important because we need to trim the qoutations at the first and last before injecting
      if (item_type == "String") {
        // Checking quotation type of the string
        var quote_type = check_string_qoutation(trimmed_item);

        // 'me' or "me"
        if (quote_type == "Single" || quote_type == "Double") {
          last_value = last_value.replaceAll("{" + item + "}",
              trimmed_item.substring(1, trimmed_item.length - 1));
          continue;
        }

        // """me"""
        if (quote_type == "Triple") {
          last_value = last_value.replaceAll("{" + item + "}",
              trimmed_item.substring(3, trimmed_item.length - 3));
          continue;
        }

        // Error
        if (quote_type == "Confused") {
          return "invalid_syntax";
        }
      }

      // If the item is not a String, then just inject.
      last_value = last_value.replaceAll("{" + item + "}", "$trimmed_item");
    }

    // Special types
    if (special_types.contains(item_type)) {
      // Variable
      if (item_type == "Variable") {
        // Checking if the vars exists

        // var exists
        if (runtime_variables.keys.contains(trimmed_item)) {
          var stored_value = runtime_variables[trimmed_item];

          // Checking type
          var var_type = check_type(stored_value);

          // If the item is String
          if (var_type == "String") {
            // Checking quotation type of the string
            var quote_type = check_string_qoutation(stored_value);

            // 'me' or "me"
            if (quote_type == "Single" || quote_type == "Double") {
              last_value = last_value.replaceAll("{" + item + "}",
                  stored_value.substring(1, stored_value.length - 1));
              continue;
            }

            // """me"""
            if (quote_type == "Triple") {
              last_value = last_value.replaceAll("{" + item + "}",
                  stored_value.substring(3, stored_value.length - 3));
              continue;
            }

            // Error
            if (quote_type == "Confused") {
              return "invalid_syntax";
            }
          }

          // If the item is not a String, then just inject.
          last_value = last_value.replaceAll("{" + item + "}", "$stored_value");
        }

        // var doesn't exist
        if (runtime_variables.keys.contains(trimmed_item) == false) {
          return "variable_not_found:$trimmed_item";
        }
      }

      // Operation
      if (item_type == "Operation") {
        var result = perform_math(trimmed_item);

        // Invalid syntax
        if (result == "invalid") {
          return "invalid_syntax";
        }

        // Division by zero
        if (result == "zero") {
          return "zero_division_error";
        }

        last_value = last_value.replaceAll("{" + item + "}", "$result");
      }
    }
  }

  if (last_value.contains("\\n")) {
    // Checking string quotation type
    var quote_type = check_string_qoutation(last_value);

    if (quote_type == "Single" || quote_type == "Double") {
      last_value = last_value
          .substring(1, last_value.length - 1)
          .replaceAll("\\n", "\n");

      // Return the value
      return last_value;
    }
  }
  return last_value;
}
