// ignore_for_file: non_constant_identifier_names

import 'package:chalkdart/chalk.dart';

// A possible error for invalid syntax
void invalid_syntax(line) {
  print(chalk.red(
      "Syntax Error: A possible syntax error has been detected.\nError on line $line"));
}

// Variable doesn't exist
void variable_not_found(var_name, line) {
  print(chalk.red(
      "VariableNotFound Error: No variable called $var_name exists.\nError on line $line"));
}

// ZeroDivisionError
void zero_division_error(line) {
  print(chalk.red(
      "ZeroDivision Error: Can't perform division by 0.\nError on line $line"));
}

// Importing from same file (import file1 while running file1)
void import_error(filename, line) {
  print(chalk.red(
      "Import Error: You are trying to import $filename.sp while executing $filename.sp\nError on line $line"));
}

// A file that was supposed to be imported doesn't exist
void file_doesnt_exist(filename, dirpath, line) {
  print(chalk.red(
      "File $filename was not found.\nMake sure $filename is present in {dirpath}\nError on line $line"));
}
