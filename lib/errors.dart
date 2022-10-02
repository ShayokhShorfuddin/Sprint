// ignore_for_file: non_constant_identifier_names
import 'package:chalkdart/chalk.dart';

// This function makes texts red! Nothing else
String colorize(String text, int line) {
  return chalk.red("$text\nError on line $line");
}

/////// Errors Starting From Here /////////

// Variable doesn't exist
variable_not_found(variable_name, line) {
  String error =
      "Variable Not Found Error: No variable called '$variable_name' exists.";
  print(colorize(error, line));
}

// List index out of range
index_out_of_range(max_lenth, line) {
  String error =
      "Index Error: Index is out of range. Maximum index is $max_lenth.";
  print(colorize(error, line));
}

// Index is not integer but some other type
invalid_index(given_invalid_index, line) {
  String error =
      "Invalid Index Error: $given_invalid_index is not a valid index. Index must be an integer.";
  print(colorize(error, line));
}

// A possible error for invalid syntax
invalid_syntax(line) {
  String error = "Syntax Error: A possible syntax error has been detected.";
  print(colorize(error, line));
}

// Built_in function or custom function doesn't exist.  (Basically saying a function user is trying to call but it doesn't exist)
function_doesnt_exist(function_name, line) {
  String error =
      "Function Not Found Error: Function $function_name doesn't exist.";
  print(colorize(error, line));
}

// ZeroDivisionError
zero_division_error(line) {
  String error = "Zero Division Error: Can't perform division by 0.";
  print(colorize(error, line));
}

// Importing from same file (import file1 while running file1)
import_error(filename, line) {
  String error =
      "Import Error: You are trying to import $filename.sp while executing $filename.sp";
  print(colorize(error, line));
}

// A file that was supposed to be imported doesn't exist
file_doesnt_exist(filename, dirpath, line) {
  String error =
      "File $filename was not found.\nMake sure $filename is present in $dirpath";
  print(colorize(error, line));
}

// Invalid variable name
invalid_variable_name(name, line) {
  String error =
      "InvalidVariableName Error: $name is not a valid variable name.";
  print(colorize(error, line));
}

// An Unexpected "end" keyword is detected
unexpected_end_keyword(line) {
  String error = "UnexpectedEnd Error: An unexpected end keyword is found.";
  print(colorize(error, line));
}
