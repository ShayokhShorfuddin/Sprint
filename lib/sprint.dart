// ignore_for_file: non_constant_identifier_names
import 'dart:io';
import 'fancy.dart';
import 'errors.dart';
import 'helpers.dart';
import 'package:chalkdart/chalk.dart';
import 'main_code_helpers.dart';

void main(List<String> args) {
  run(args);
}

String sprint_version = "Sprint 1.1";

// Opening Files
dynamic open_file(filename) async {
  var data = File(filename);

  // Checking if the file exists or not
  if (await data.exists()) {
    return data;
  }
  if (await data.exists() == false) {
    var dirpath = Directory.current.path;
    print(chalk.red(
        "File '$filename' not found!\nMake sure $filename is present in $dirpath"));
    exit(0);
  }
}

// Lexing Code
dynamic sprint_lexer(File filecontent, args) async {
  // every lines of code without \n
  var code_lines = filecontent.readAsLinesSync();

  // storage for tokens of every line
  List all_tokens = [];

  // tokenizing every lines of code
  int line_no = 1;
  bool multi_comment_alert = false;

  try {
    for (var line in code_lines) {
      // Removing all leading and trailing whitespace
      line = line.trim();

      // Ignoring empty lines
      if (line.isEmpty) {
        all_tokens.add(["Ignore:Space", "Ignore:Space"]);
        line_no = line_no + 1;
        continue;
      }

      // Removing comment lines
      if (line.startsWith("#") || line.startsWith("//")) {
        all_tokens.add(["Ignore:Comment", "Ignore:Comment"]);
        line_no = line_no + 1;
        continue;
      }

      // Starting """
      if (line == '"""' || line.startsWith('"""')) {
        // multi_comment_alert should be false

        if (multi_comment_alert == false) {
          multi_comment_alert = true;
          all_tokens.add(["Ignore:Comment", "Ignore:Comment"]);
          line_no = line_no + 1;
          continue;
        }
      }

      // Middle lines
      if (line.startsWith('"""') == false && line.endsWith('"""') == false) {
        // multi_comment_alert should be true

        if (multi_comment_alert == true) {
          all_tokens.add(["Ignore:Comment", "Ignore:Comment"]);
          line_no = line_no + 1;
          continue;
        }
      }

      // Ending """
      if (line == '"""' || line.endsWith('"""')) {
        // multi_comment_alert should be true

        if (multi_comment_alert == true) {
          multi_comment_alert = false;
          all_tokens.add(["Ignore:Comment", "Ignore:Comment"]);
          line_no = line_no + 1;
          continue;
        }
      }

      // Removing ; from each line
      if (line.endsWith(";")) {
        line = line.substring(0, line.length - 1);
      }

      // Syntax #1  (import file1, file2)
      if (line.startsWith("import")) {
        var result = await import_token_processor(line, args);

        // Checking if there is any error returned
        if (result == "invalid_syntax") {
          invalid_syntax(line_no);
          exit(0);
        }

        if (result is String && result.startsWith("import_error")) {
          import_error(
              result.split(":")[1], line_no); // result --> import_error:file1
          exit(0);
        }

        if (result == "file_doesnt_exist") {
          var dirpath = Directory.current.path;
          file_doesnt_exist(result.split(":")[1], dirpath, line_no);
          exit(0);
        }

        String files_in_string = result.join(",");
        all_tokens.add(["Identifier:Import", "Files:$files_in_string"]);
        line_no = line_no + 1;
        continue;
      }

      // Syntax #2  (from file1 import a, b)

      if (line.startsWith("from") && line.contains("import ")) {
        var result = await from_token_processor(line, args);

        // Checking if there is any error returned
        if (result == "invalid_syntax") {
          invalid_syntax(line_no);
          exit(0);
        }

        if (result is String && result.startsWith("import_error")) {
          import_error(
              result.split(":")[1], line_no); // result --> import_error:file1
          exit(0);
        }

        if (result == "file_doesnt_exist") {
          var dirpath = Directory.current.path;
          file_doesnt_exist(result.split(":")[1], dirpath, line_no);
          exit(0);
        }

        String file_and_vars_in_string = result.join(",");
        all_tokens
            .add(["Identifier:From", "File-Vars:$file_and_vars_in_string"]);
        line_no = line_no + 1;
        continue;
      }

      // Print
      if (line.contains("print")) {
        // Getting the word to print
        var target = customsplit(line, " ", max: 1)[1].trim();
        var target_type = check_type(target);

        all_tokens.add(["Identifier:Print", "$target_type:$target"]);
        line_no = line_no + 1;
        continue;
      }

      // Variable
      if (line.contains("=") && line.split("=").length == 2) {
        var variable_name = line.split("=")[0].trim();
        var variable_value = line.split("=")[1].trim();
        var target_type = check_type(variable_value);
        all_tokens.add(["Var:$variable_name", "$target_type:$variable_value"]);
        line_no = line_no + 1;
        continue;
      }

      // Exit (Terminate program execution)
      if (line == "exit" || line == "Exit") {
        all_tokens.add(["Command:Exit", "Command:Exit"]);
        line_no = line_no + 1;
        continue;
      }

      // If it just doesn't make sense
      else {
        invalid_syntax(line_no);
        exit(0);
      }
    }
    return all_tokens;
  } catch (e) {
    invalid_syntax(line_no);
    exit(0);
  }
}

// Parsing Tokens
void sprint_parser(tokens) {
  // Variable Storage
  Map runtime_variables = {};
  int line_no = 1;
  List normal_types = ["Integer", "String", "Boolean", "Float", "List", "Dict"];
  List special_types = ["Operation", "Variable"];

  // Processing Tokens
  for (var token in tokens) {
    // First point
    var first = token[0];
    var first_type = first.split(":")[0];
    var first_value = first.split(":")[1];

    // Last point
    var last = token[1];
    var last_type = customsplit(last, ":", max: 1)[0];
    var last_value = customsplit(last, ":", max: 1)[1];

    // Ignore
    if (first_type == "Ignore") {
      line_no = line_no + 1;
      continue;
    }

    // Identifier
    if (first_type == "Identifier") {
      // Print
      if (first_value == "Print") {
        // Checking Type
        if (normal_types.contains(last_type)) {
          // Using print_processor to process last_value
          var result =
              print_processor(last_type, last_value, runtime_variables);

          // For errors
          if (result == "invalid_syntax") {
            invalid_syntax(line_no);
            exit(0);
          }

          if (result.startsWith("variable_not_found")) {
            variable_not_found(
                result.split(":")[1], line_no); // variable_not_found:joe
            exit(0);
          }

          if (result == "zero_division_error") {
            zero_division_error(line_no);
            exit(0);
          }
          // If everything is OK, we finally print the output!
          print(result);
        }

        if (special_types.contains(last_type)) {
          // Variable
          if (last_type == "Variable") {
            // Checking if the target variable exists or not
            if (runtime_variables.keys.contains(last_value)) {
              // Var exists
              var stored_value = runtime_variables[last_value];

              // Using print_processor to process stored_value
              var result = print_processor(check_type("$stored_value"),
                  "$stored_value", runtime_variables);

              // For errors
              if (result == "invalid_syntax") {
                invalid_syntax(line_no);
                exit(0);
              }

              if (result.startsWith("variable_not_found")) {
                variable_not_found(
                    result.split(":")[1], line_no); // variable_not_found:joe
                exit(0);
              }

              if (result == "zero_division_error") {
                zero_division_error(line_no);
                exit(0);
              }

              print(result);
              continue;
            }

            if (runtime_variables.keys.contains(last_value) == false) {
              variable_not_found(last_value, line_no);

              var result = variable_suggestor(last_value, runtime_variables);
              if (result != null) {
                // This means that a suggestion is available!
                print(result);
              }
              exit(0);
            }
          }

          // Operation
          if (last_type == "Operation") {
            var result = perform_math(last_value);

            // Invalid syntax
            if (result == "invalid") {
              invalid_syntax(line_no);
              exit(0);
            }

            // Division by zero
            if (result == "zero") {
              zero_division_error(line_no);
              exit(0);
            }

            print(result);
            continue;
          }
        }
      }

      // Import
      if (first_value == "Import") {
        var result = import_processor(last_value);

        // Errors
        if (result == "invalid_syntax") {
          invalid_syntax(line_no);
          exit(0);
        }

        if (result == "zero_division_error") {
          zero_division_error(line_no);
          exit(0);
        }

        if (result is String && result.startsWith("variable_not_found")) {
          variable_not_found(
              result.split(":")[1], line_no); // variable_not_found:joe
          exit(0);
        }

        for (var new_var_key in result.keys) {
          var new_var_value = result[new_var_key];
          runtime_variables[new_var_key] = new_var_value;
        }
      }

      // From Import
      if (first_value == "From") {
        var result = from_processor(last_value);

        // Errors
        if (result == "invalid_syntax") {
          invalid_syntax(line_no);
          exit(0);
        }

        if (result == "zero_division_error") {
          zero_division_error(line_no);
          exit(0);
        }

        if (result is String && result.startsWith("variable_not_found")) {
          variable_not_found(
              result.split(":")[1], line_no); // variable_not_found:joe
          exit(0);
        }

        for (var new_var_key in result.keys) {
          var new_var_value = result[new_var_key];
          runtime_variables[new_var_key] = new_var_value;
        }
      }
    }

    if (first_type == "Var") {
      // Checking the type of last_value
      String value_type = check_type(last_value);

      // Integer
      if (value_type == "Integer") {
        runtime_variables[first_value] = int.parse(last_value);
      }

      // String
      if (value_type == "String") {
        // Using string processor to process last_value before saving to variable
        var result = string_processor(last_value, runtime_variables);

        // Errors
        if (result == "invalid_syntax") {
          invalid_syntax(line_no);
          exit(0);
        }

        if (result == "zero_division_error") {
          zero_division_error(line_no);
          exit(0);
        }

        if (result.startsWith("variable_not_found")) {
          variable_not_found(
              result.split(":")[1], line_no); // variable_not_found:joe
          exit(0);
        }

        // Saving the processed string
        runtime_variables[first_value] = result;
      }

      // Boolean
      if (value_type == "Boolean") {
        runtime_variables[first_value] = last_value;
      }

      // Float
      if (value_type == "Float") {
        runtime_variables[first_value] = double.parse(last_value);
      }

      // Operation
      if (value_type == "Operation") {
        var result = perform_math(last_value);

        // Invalid syntax
        if (result == "invalid") {
          invalid_syntax(line_no);
          exit(0);
        }

        // Division by zero
        if (result == "zero") {
          zero_division_error(line_no);
          exit(0);
        }

        runtime_variables[first_value] = "$result";
      }

      // Variables
      if (value_type == "Variable") {
        // Checking if last_value exists or not
        if (runtime_variables.keys.contains(last_value)) {
          runtime_variables[first_value] = runtime_variables[last_value];
        }

        if (runtime_variables.keys.contains(last_value) == false) {
          variable_not_found(last_value, line_no);
          var result = variable_suggestor(last_value, runtime_variables);

          if (result != null) {
            // This means that a suggestion is available!
            print(result);
          }
          exit(0);
        }
      }
    }

    // Exit (Terminate program execution)
    if (first_type == "Command" && first_value == "Exit") {
      exit(0);
    }

    line_no = line_no + 1;
  }
}

// Running Programs
void run(args) async {
  // If no file is given
  if (args.length == 0) {
    print("\n");
    print(sprint_ascii);
    print("\n");
    print(
        "Hello there!\nTo run sprint programs, simply execute - 'sprint hello_world.sp'. Happy coding!");
  }

  // If a file (or --version) is given
  if (args.length == 1) {
    // For "--version"
    if (args[0] == "--version") {
      print(sprint_version);
    }

    // Assuming its a file
    if (args[0] != "--version") {
      var data = await open_file(args[0]);
      var prepared_tokens = await sprint_lexer(data, args);
      sprint_parser(prepared_tokens);
    }
  }
}
