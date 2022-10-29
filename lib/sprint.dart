// ignore_for_file: non_constant_identifier_names, unused_import, prefer_typing_uninitialized_variables
import 'dart:io';
import 'terminal.dart';
import 'errors.dart';
import 'helper.dart';
import 'utilities.dart';
import 'processor.dart';
import 'package:chalkdart/chalk.dart';

String sprint_version = "1.3";

void main(List<String> args) {
  // Let's Sprint!
  run(args);
}

// Opening Code Files
dynamic open_file(filename) async {
  var data = File(filename);

  // Checking if the file exists or not
  if (await data.exists()) {
    // every lines of code without \n
    List code_lines = data
        .readAsLinesSync(); // This will produce a list containg codes line by line

    return code_lines;
  }

  // File doesn't exist
  if (await data.exists() == false) {
    var dirpath = Directory.current.path;
    print(chalk.red(
        "File '$filename' not found!\nMake sure $filename is present in $dirpath"));
    exit(0);
  }
}

// Variable Storage (runtime_variables dict stores all the variable our coder declares or updates :] )
Map runtime_variables = {};

// Lexing Code
dynamic sprint_lexer(filecontent, args) async {
  // filecontent will always be a list.
  List code_lines = filecontent;

  // line no
  int line_no = 1;

  // storage for tokens of every line
  List all_tokens = [];

  // Genesis loop details
  var iterator; // i
  var iterate_over; // "Peter"
  var iterate_over_type;

  // Nest Levels (For keeping track of nesting as loops, conditionals and functions can have deeply nested codes)
  int loop_nest_level = 0;

  // Nest Containers (For storing the codes in a loop, conditionals and functions)
  List loop_lines_list = [];

  // Alerts (For letting the lexer know that a loop, comment, conditional or function is declared or not.)
  bool loop_alert = false;
  bool multi_comment_alert = false;

  try {
    for (String line in code_lines) {
      // Removing all leading and trailing whitespace
      line = line.trim();

      // At first, checking if this line of code should be inside a loop or not  (Basically checking if loop alert is on or off)

      // If a genesis loop is already detected
      if (loop_alert == true) {
        // If another loop is detected inside the genesis loop
        if (line.contains("for ") &&
            line.contains(" in ") &&
            len(line.split(" ")) >= 4 &&
            line.endsWith(":") &&
            count(":", line) == 1) {
          loop_lines_list.add(line);
          loop_nest_level = loop_nest_level + 1;
          line_no++;
          continue;
        }

        // If we detect an "end" keyword
        if (line == "end") {
          // If end of inner loops found
          if (loop_nest_level > 1) {
            loop_lines_list.add(line);
            loop_nest_level = loop_nest_level - 1;
            line_no++;
            continue;
          }

          // If end of genesis loops found
          if (loop_nest_level == 1) {
            all_tokens.add([
              "Loop:$iterator",
              "$iterate_over_type:$iterate_over",
              {"Lines": loop_lines_list}
            ]);
            loop_nest_level = 0;
            loop_alert = false;
            loop_lines_list = [];
            line_no++;
            continue;
          }
        }

        loop_lines_list.add(line);
        line_no++;
      }

      // If its just a regular normal line that is not nested inside a loop

      if (loop_alert == false && loop_nest_level == 0) {
        // Encountering the start of a for loop
        if (line.contains("for ") &&
            line.contains(" in ") &&
            len(line.split(" ")) >= 4 &&
            line.endsWith(":") &&
            count(":", line) == 1) {
          String new_line = removeLast(line)
              .trim(); // Removing the ":" at the end of the line

          List temp_list = new_line.split(" "); // ['for', 'i', 'in', '"Peter"']

          iterator = temp_list[1].trim(); // i
          iterate_over = temp_list[3].trim(); // "Peter"
          iterate_over_type =
              check_type(iterate_over); // Checking the type of iterate_over

          loop_alert = true;
          loop_nest_level = loop_nest_level + 1;
          line_no++;
          continue;
        }

        // if an unexpected "end" is found
        if (line == "end") {
          unexpected_end_keyword(line_no); // Raising error!
          exit(0);
        }

        // Ignoring empty lines
        if (line.isEmpty) {
          all_tokens.add(["Ignore:Space"]);
          line_no++;
          continue;
        }

        // Removing comment lines
        if (line.startsWith("#") || line.startsWith("//")) {
          all_tokens.add(["Ignore:Comment"]);
          line_no++;
          continue;
        }

        /*
             """
             Lol
            """
        */

        // Removing multi-line comments

        // Starting """
        if (line == '"""' || line.startsWith('"""')) {
          // multi_comment_alert should be false

          if (multi_comment_alert == false) {
            multi_comment_alert = true;
            all_tokens.add(["Ignore:Comment"]);
            line_no++;
            continue;
          }
        }

        // Middle lines
        if (line.startsWith('"""') == false && line.endsWith('"""') == false) {
          // multi_comment_alert should be true

          if (multi_comment_alert == true) {
            all_tokens.add(["Ignore:Comment"]);
            line_no++;
            continue;
          }
        }

        // Ending """
        if (line == '"""' || line.startsWith('"""') || line.endsWith('"""')) {
          // multi_comment_alert should be true

          if (multi_comment_alert == true) {
            multi_comment_alert = false;
            all_tokens.add(["Ignore:Comment"]);
            line_no++;
            continue;
          }
        }

        // Removing ; from each line
        if (line.endsWith(";")) {
          line = line.substring(0, line.length - 1);
        }

        // Importing
        // There are two types of import syntax:  import filename, from filename import a, b, c

        // Syntax #1  (import file1, file2)
        if (line.startsWith("import ")) {
          var result = await import_token_processor(line, args);

          // Checking if there is any error returned
          if (result == "invalid_syntax") {
            invalid_syntax(line_no);
            exit(0);
          }

          // using type(result) because if result is a list, result.startswith() causes issue
          if (result is String && result.startsWith("import_error")) {
            import_error(
                result.split(":")[1], line_no); // result --> import_error:file1
            exit(0);
          }

          if (result is String && result.startsWith("file_doesnt_exist")) {
            var dirpath = Directory.current.path;
            file_doesnt_exist(result.split(":")[1], dirpath, line_no);
            exit(0);
          }

          String files_in_string = result.join(
              ","); // if everything is alright, result will be a list containing the filenames
          all_tokens.add(["Keyword:Import", "Files:$files_in_string"]);
          line_no++;
          continue;
        }

        // Syntax #2  (from file1 import a, b)
        if (line.startsWith("from ") && line.contains(" import ")) {
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

          if (result is String && result == "file_doesnt_exist") {
            var dirpath = Directory.current.path;
            file_doesnt_exist(result.split(":")[1], dirpath, line_no);
            exit(0);
          }

          String file_and_vars_in_string = result.join(
              ","); // if everything is alright, result will be a list containing the filename and variables. Filename will be in position 0
          all_tokens
              .add(["Keyword:From", "File-Vars:$file_and_vars_in_string"]);
          line_no++;
          continue;
        }

        // Print
        if (line.contains("print")) {
          // Getting the word to print
          var target = customsplit(line, " ", max: 1)[1].trim();
          var target_type = check_type(target);

          all_tokens.add(["Keyword:Print", "$target_type:$target"]);
          line_no++;
          continue;
        }

        // Variable
        if (line.contains("=") && line.split("=").length == 2) {
          var variable_name = line.split("=")[0].trim();
          var variable_value = line.split("=")[1].trim();
          var target_type = check_type(variable_value);

          all_tokens
              .add(["Var:$variable_name", "$target_type:$variable_value"]);
          line_no++;
          continue;
        }

        // Exit (Terminate program execution)
        if (line == "exit" || line == "Exit" || line == "EXIT") {
          all_tokens.add(["Keyword:Exit"]);
          line_no++;
          continue;
        }

        // If it just doesn't make sense
        else {
          invalid_syntax(line_no);
          exit(0);
        }
      }
    }
    return all_tokens;
    // If a line doesn't make any sense, we will raise syntax error
  } catch (e) {
    invalid_syntax(line_no);
    exit(0);
  }
}

// Parsing Tokens
sprint_parser(List tokens, args) async {
  // Line no
  int line_no = 1;

  List normal_types = [
    "Integer",
    "String",
    "Boolean",
    "Float",
    "List",
    "Dict"
  ]; // List and Dict is useless for this update

  List special_types = [
    "Math",
    "Variable"
  ]; // special types basically mean "There is some work to do with the data". The "Math" type is for equations like "2 + 2" and our parser actually needs to perform this math. The "Variable" is for making the parser know that our coder has declared/updated a variable and it needs to save/update that variable.

  // Ok here we go!

  // Processing Tokens
  for (List token in tokens) {
    // Before we Sprint, we need to determine what to do by checking the length of the token

    // Length 3 means serious nesting stuffs like loops
    // Length 2 means somewhat normal stuff like variables, print, import
    // Length 1 means absolutely normal stuff like exit, whitespace lines

    int token_length = len(token);

    // Length 1
    if (token_length == 1) {
      String first_type = token[0].split(":")[0];

      // Ignore
      if (first_type == "Ignore") {
        line_no++;
        continue;
      }

      // Exit (Terminate program execution)
      if (first_type == "Exit") {
        exit(0);
      }
    }

    // Length 2
    if (token_length == 2) {
      // First point
      String first = token[0];
      String first_type = first.split(":")[0];
      String first_value = first.split(":")[1];

      // Last point
      String last = token[1];
      String last_type = customsplit(last, ":", max: 1)[0];
      String last_value = customsplit(last, ":", max: 1)[1];

      // Dealing with "Keyword"
      if (first_type == "Keyword") {
        // Print Keyword
        if (first_value == "Print") {
          // Checking Type

          // If last_type is in normal types
          if (normal_types.contains(last_type)) {
            // Using print_processor to process last_value
            var result =
                print_processor(last_type, last_value, runtime_variables);

            // For errors
            if (result == "invalid_syntax") {
              invalid_syntax(line_no);
              exit(0);
            }

            if (result is String && result.startsWith("variable_not_found")) {
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

          // If last_type is in special types

          if (special_types.contains(last_type)) {
            // Variable

            if (last_type == "Variable") {
              // Checking if the target variable exists or not

              // Var exists
              if (runtime_variables.keys.contains(last_value)) {
                var stored_value = runtime_variables[last_value];

                // Using print_processor to process stored_value
                var result = print_processor(check_type("$stored_value"),
                    "$stored_value", runtime_variables);

                // For errors
                if (result == "invalid_syntax") {
                  invalid_syntax(line_no);
                  exit(0);
                }

                if (result is String &&
                    result.startsWith("variable_not_found")) {
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
                continue;
              }

              // Var doesn't exist
              if (runtime_variables.containsKey(last_value) == false) {
                variable_not_found(last_value, line_no);

                var result = variable_suggestor(last_value, runtime_variables);

                if (result != null) {
                  // This means that a suggestion is available!
                  print(result);
                }
                exit(0);
              }
            }

            // Math
            if (last_type == "Math") {
              var result = perform_math(last_value);

              // Invalid syntax
              if (result == "Invalid") {
                invalid_syntax(line_no);
                exit(0);
              }

              // Division by zero
              if (result == "Zero") {
                zero_division_error(line_no);
                exit(0);
              }

              print(result);
              continue;
            }
          }
        }

        // Import Keyword

        if (first_value == "Import") {
          // Getting thes files list
          List file_list = last_value.split(",");

          // Running a for loop so that we can extract and add the variables of all the given file one by one
          for (var filename in file_list) {
            // Using variable_importer to importer all the variables
            var result = variable_importer(filename);

            // The result can either be a dict of imported variables or a list containing a variable that was not found (error)
            // Error
            if (result is List) {
              variable_not_found(result[0], line_no); // ["joe"]
              exit(0);
            }

            // Success
            if (result is Map) {
              // Running a for loop to add all the variables to this runtime_variables
              for (var i in result.keys) {
                // Adding...
                runtime_variables[i] = result[i].toString();
              }
            }
          }
        }

        // From Keyword
        if (first_value == "From") {
          // Using temp list for help
          List temp_list = last_value.split(",");

          // Extracting the filename and variables
          // Filename
          var filename = temp_list[0];

          // Variables
          temp_list.removeAt(0); // removing the filename from the list
          List expected_variables = temp_list;

          // Using variable_importer to importer all the variables
          var result = variable_importer(filename, expected_variables);

          // The result can either be a dict of imported variables or a list containing a variable that was not found (error)
          // Error
          if (result is List) {
            variable_not_found(result[0], line_no); // ["joe"]
            exit(0);
          }

          // Success
          if (result is Map) {
            // Running a for loop to add all the variables to this runtime_variables
            for (var i in result.keys) {
              // Adding...
              runtime_variables[i] = result[i].toString();
            }
          }
        }
      }

      /////////// Variable line Processor ////////////////

      // This part processes variables lines like this (name = "Shayokh"). Basically saves the last_value to runtime_variables depending on last_value type
      if (first_type == "Var") {
        // At first, checking if the variable name is valid
        if (variable_name_validator(first_value) == "Invalid") {
          invalid_variable_name(first_value, line_no);
          exit(0);
        }

        // Checking the type of last_value
        String value_type = check_type(last_value);

        // Integer
        if (value_type == "Integer") {
          runtime_variables[first_value] = integer(last_value);
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

          if (result is String && result.startsWith("variable_not_found")) {
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
          runtime_variables[first_value] = float(last_value);
        }

        // For special types

        // Math
        if (value_type == "Math") {
          var result = perform_math(last_value);

          // Invalid syntax
          if (result == "Invalid") {
            invalid_syntax(line_no);
            exit(0);
          }

          // Division by zero
          if (result == "Zero") {
            zero_division_error(line_no);
            exit(0);
          }

          runtime_variables[first_value] = "$result";
        }

        // Variables
        if (value_type == "Variable") {
          // Checking if last_value exists or not

          // Exists
          if (runtime_variables.containsKey(last_value)) {
            runtime_variables[first_value] = runtime_variables[last_value];
          }

          // Doesn't Exist
          if (runtime_variables.containsKey(last_value) == false) {
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
    }

    // Length 3
    if (token_length == 3) {
      // Getting type of the nesting thing (loop, conditional or function ?)
      String thing_type = token[0].split(':')[0];

      // Processing For Loops
      if (thing_type == 'Loop') {
        // Extracting necessary data from the token

        String iterator = token[0].split(":")[1]; // i
        String iterate_over = token[1].split(":")[1]; // "Peter"
        String iterate_over_type = token[1].split(":")[0]; // String
        List lines = token[2]["Lines"];

        // for this situation -->   for "i" in "Peter":
        if (check_type(iterator) == "String") {
          invalid_syntax(line_no);
          exit(0);
        }

        // Real fun begins now

        // We need to keep in mind that iterate_over can be a String or List or variable representing a String or List

        // String
        if (iterate_over_type == "String") {
          var result = string_processor(iterate_over, runtime_variables);

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

          String clean_string = remove_quotation(result);
          List iterate_over_list = clean_string.split("");

          // Preparing tokens
          var prepared_tokens = await sprint_lexer(lines, args);

          // Main for loop
          for (var element in iterate_over_list) {
            // Assigning "i" to the current element and saving into runtime_variables
            runtime_variables[iterator] = element;

            // Now we can run the code inside the loop :]
            sprint_parser(prepared_tokens, args);
          }
        }

        // Variable (the variable can potentially represent a String or list)
        if (iterate_over_type == "Variable") {
          String target = "";

          // Checking if the variable exists or not

          // Exists
          if (runtime_variables.containsKey(iterate_over)) {
            target = runtime_variables[iterate_over];
          }

          // Doesn't exist
          if (runtime_variables.containsKey(iterate_over) == false) {
            variable_not_found(iterate_over, line_no);
            exit(0);
          }

          // Checking target type
          String target_type = check_type(target);

          // String
          if (target_type == "String") {
            var result = string_processor(target, runtime_variables);

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

            String clean_string = remove_quotation(result);
            List iterate_over_list = clean_string.split("");

            // Preparing tokens
            var prepared_tokens = await sprint_lexer(lines, args);

            // Main for loop
            for (var element in iterate_over_list) {
              // Assigning "i" to the current element and saving into runtime_variables
              runtime_variables[iterator] = element;

              // Now we can run the code inside the loop :]
              sprint_parser(prepared_tokens, args);
            }
          }
        }
      }
    }

    line_no++;
  }
}

// Running Programs
run(args) async {
  // If no command / file is given, only "sprint".
  if (args.length == 0) {
    print("Sprint $sprint_version ⚡");
    print(terminal_utilities);
  }

  // If a command / filename is given.
  if (args.length >= 1) {
    List commands = ["create", "list", "delete", "version"];

    // If its a command...
    if (commands.contains(args[0])) {
      // Version
      if (args[0] == "version") {
        print("Sprint $sprint_version ⚡");
      }

      // Create
      if (args[0] == "create") {
        create_command(args);
      }

      // List
      if (args[0] == "list") {
        list_files();
      }

      // Delete
      if (args[0] == "delete") {
        delete_command(args);
      }

      return;
    }

    // if its a filename...
    if (commands.contains(args[0]) == false && args[0].endsWith(".sp")) {
      sprint_interpreter(args);
    }

    // if its not a command / filename
    else {
      error(args[0]);
    }
  }
}

void sprint_interpreter(List args) async {
  // "data" is all the raw code extracted from the code file
  var data = await open_file(args[0]);
  var prepared_tokens = await sprint_lexer(data, args);
  sprint_parser(prepared_tokens, args);
}
