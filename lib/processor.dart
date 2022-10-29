// ignore_for_file: non_constant_identifier_names

// Processors will make our life much much easier
// They basically take a data from us, do some magic and return a useful and formatted data to us!
// Also it helps us keep all the big code lines out of sprint.py and only give us the data we need to work with, eventually keeping sprint.py file short.

import 'dart:io';
import 'helper.dart';
import 'utilities.dart';

List normal_types = ["Integer", "String", "Boolean", "Float", "List", "Dict"];
List special_types = ["Math", "Variable"];

/*
Print processor (print a)
Takes in the last_type and last_value, returns the perfectly formatted and ready-to-print output
*/

// runtime_variables are necessary

dynamic print_processor(last_type, last_value, Map runtime_variables) {
  // For processing String (We will use string_processor to process strings)
  if (last_type == "String") {
    var processed_string = string_processor(last_value, runtime_variables);
    return processed_string;
  }

  // Finally, We will return our print-ready value!
  return last_value;
}

/*
String processor ('Hello {name}\nReady to Sprint?')
Takes in the string (last_value) and runtime_variables, returns a perfectly processed string
*/

dynamic string_processor(last_value, Map runtime_variables) {
  // Getting a list of all the {} in string
  List string_formatters =
      string_items_extractor(last_value); // [' "me" ', '  you ', '2 + 2']

  for (var item in string_formatters) {
    var trimmed_item = item.trim(); // "me"

    // Checking the type of the item
    var item_type = check_type(trimmed_item);

    // Normal types
    if (normal_types.contains(item_type)) {
      // For string item
      // If the item is a String. This is important because we need to trim the qoutations at the first and last before injecting

      if (item_type == "String") {
        // Checking quotation type of the string
        var quote_type = check_string_type(trimmed_item);

        // 'me' or "me"
        if (quote_type == "Single" || quote_type == "Double") {
          last_value = last_value.replaceAll(
              "{$item}", trimmed_item.substring(1, trimmed_item.length - 1));
          continue;
        }

        // """me"""
        if (quote_type == "Triple") {
          last_value = last_value.replaceAll(
              "{$item}", trimmed_item.substring(3, trimmed_item.length - 3));
          continue;
        }

        // Error
        if (quote_type == "Invalid") {
          return "invalid_syntax";
        }
      }

      // If the item is not a String, then just inject.
      last_value = last_value.replaceAll("{$item}", "$trimmed_item");
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
            var quote_type = check_string_type(stored_value);

            // 'me' or "me"
            if (quote_type == "Single" || quote_type == "Double") {
              last_value = last_value.replaceAll("{$item}",
                  stored_value.substring(1, stored_value.length - 1));
              continue;
            }

            // """me"""
            if (quote_type == "Triple") {
              last_value = last_value.replaceAll("{$item}",
                  stored_value.substring(3, stored_value.length - 3));
              continue;
            }

            // Error
            if (quote_type == "Invalid") {
              return "invalid_syntax";
            }
          }

          // If the item is not a String, then just inject.
          last_value = last_value.replaceAll("{$item}", "$stored_value");
        }

        // var doesn't exist
        if (runtime_variables.keys.contains(trimmed_item) == false) {
          return "variable_not_found:$trimmed_item";
        }
      }

      // Math
      if (item_type == "Math") {
        double result = perform_math(trimmed_item);

        // Invalid syntax
        if (result == "Invalid") {
          return "invalid_syntax";
        }

        // Division by zero
        if (result == "Zero") {
          return "zero_division_error";
        }

        last_value = last_value.replaceAll("{$item}", "$result");
      }
    }
  }

  // Oof we just finished injecting all the items into the string. Now we can move on

  // Applying all special charecters to Strings with single or double qoutations
  // Checking string quotation type

  String quote_type = check_string_type(last_value);

  if (quote_type == "Single" || quote_type == "Double") {
    bool newline_alert =
        false; // We want to remove the single or double qoutation when returning if there is a newline in string. Thats why we will use newline_alert

    // Newline (\n) || Add a newline into string
    if (last_value.contains("\\n")) {
      newline_alert = true;
      last_value = last_value.replaceAll("\\n", "\n");
    }

    // Tab (\t) || Add a Tab into string
    if (last_value.contains("\\t")) {
      last_value = last_value.replaceAll("\\t", "    ");
    }

    // For newline
    if (newline_alert == true) {
      return last_value.substring(1, last_value.length - 1);
    }
  }

  // Returning the perfect String
  return last_value;
}

/*
Import processor (import file1, file2)
Takes in the code line (import file1, file2), returns the files list (file_list)
*/

// argv is required for checking if any of the files (file1, file2) is the currently executing file
// async is necessary for checking if file exists

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

    // Doesn't exist
    if (await data.exists() == false) {
      return "file_doesnt_exist:$target_file"; // Sending the name of the file with the string
    }

    // Checking if target_file is the currently executing file
    if ("$target_file.sp" == argv[0]) {
      return "import_error:$target_file"; // Sending the name of the file with the string
    }
  }

  // Returning the ultimate list of fresh filenames
  return file_list;
}

/*
From processor (from file1 import var1, var2)
Takes in the code line (from file1 import var1, var2), returns the filename and expected variables
*/

// argv is required for checking if target_file (file1) is the currently executing file
// async is necessary for checking if file exists

dynamic from_token_processor(line, argv) async {
  List expected_variables = [];

  // Temp list for making things a little easy
  List temp_list = line.split("import"); // ["from file1", "a, b"]

  var filename = temp_list[0].split(" ")[1].trim(); // file1
  List unstriped_variables = temp_list[1].split(","); // ["a", "b"]

  // For this situation : (from test2 import name:, age) --> [' name:', ' age']  That ":" can cause spliting issues
  for (String i in unstriped_variables) {
    if (i.contains(":")) {
      return "invalid_syntax";
    }
  }

  // For situations like this: from file1 import , a (Output - ['', 'a'])
  for (var i in unstriped_variables) {
    if (i.trim() == "") {
      return "invalid_syntax";
    }
  }

  // Removing extra spaces at the start and end of variables and adding to target_variables
  for (var i in unstriped_variables) {
    i = i.trim();
    expected_variables.add(i);
  }

  // Checking if target_file exists in current folder
  var data = File("$filename.sp");

  // File exists
  if (await data.exists()) {}

  // Doesn't exist
  if (await data.exists() == false) {
    return "file_doesnt_exist:$filename"; // Sending the name of the file with the string
  }
  // Checking if target_file is the currently executing file
  if ("$filename.sp" == argv[0]) {
    return "import_error:$filename"; // Sending the name of the file with the string
  }

  // Adding our clean filename at the first of expected_variables
  expected_variables.insert(0, filename);

  var files_and_vars =
      expected_variables; // target_variables contains the filename in position 0

  return files_and_vars;
}

/*
Variable Importer (Imports variables from given file)
Takes in a filename, imports all the variables it detects and returns a dictionary of variables (extracted_variables)
*/

// wanted_vars is for situations when coder wants only specific variables using "from" keyword

dynamic variable_importer(filename, [wanted_vars]) {
  Map extracted_variables = {};

  // First, we will read the content of the file
  var data = File("$filename.sp");
  List code_lines = data.readAsLinesSync();

  // Looping through every lines of code in search of variables
  for (String line in code_lines) {
    // Detecting variables
    if (line.contains("=") && line.split("=").length == 2) {
      var variable_name = line.split("=")[0].trim();
      var variable_value = line.split("=")[1].trim();
      var value_type = check_type(variable_value);

      // Integer
      if (value_type == "Integer") {
        extracted_variables[variable_name] = integer(variable_value);
      }

      // String
      if (value_type == "String") {
        extracted_variables[variable_name] = variable_value;
      }

      // Boolean
      if (value_type == "Boolean") {
        extracted_variables[variable_name] = variable_value;
      }

      // Float
      if (value_type == "Float") {
        extracted_variables[variable_name] = float(variable_value);
      }

      // Math
      if (value_type == "Math") {
        var result = perform_math(variable_value);

        // Errors
        // Invalid syntax
        if (result == "Invalid") {
          return "Invalid";
        }

        // Division by zero
        if (result == "Zero") {
          return "Zero";
        }

        extracted_variables[variable_name] = "$result";
      }

      // Variables
      if (value_type == "Variable") {
        // Checking if last_value exists or not
        // Exists
        if (extracted_variables.containsKey(variable_value)) {
          extracted_variables[variable_name] =
              extracted_variables[variable_value];
        }

        // Doesn't exist
        if (extracted_variables.containsKey(variable_value) == false) {
          return [
            variable_value
          ]; // Basically returning for variable_not_found error
        }
      }
    }
  }

  // We have finished gathering all the variables from the given file
  // Now we will return variables based on whether our code wants all the variables or only certain few

  // Coder wants all the variables! (Looks like he's kinda greedy )
  if (wanted_vars == null) {
    // Returning all the extracted variables (greedy lol)
    return extracted_variables;
  }

  // Coder wants a few certain variables
  if (wanted_vars != null) {
    Map final_variables = {};

    // Checking if all the wanted_vars are present or not one by one
    for (var i in wanted_vars) {
      // Expected variable is present
      if (extracted_variables.containsKey(i)) {
        final_variables[i] = extracted_variables[i];
      }

      // Expected variable is not present/found
      if (extracted_variables.containsKey(i) == false) {
        return [i]; // Basically returning for variable_not_found error
      }
    }

    // Returning the wanted variables
    return final_variables;
  }
}
