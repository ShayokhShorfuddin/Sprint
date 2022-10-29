// ignore_for_file: non_constant_identifier_names
import 'dart:io';
import 'package:chalkdart/chalk.dart';

String terminal_utilities =
    """

Usage: sprint <command|file> [arguments]

Available commands:
  create [filename]    Create a new Sprint project.
  list                 Show a list of Sprint projects in this directory.
  version              Print the Sprint version.
  delete               Delete a Sprint project.
""";

/////////////// All Terminal Commands ///////////////////

// "Create" command
void create_command(List argv) async {
  // if filename is not given...
  if (argv.length == 1) {
    print(chalk
        .red('Provide a filename.\nExample - "sprint create hello_world"'));
  }

  // Filename is given
  if (argv.length >= 2) {
    await File('${Directory.current.path}/${argv[1]}.sp').create();
    print("Done!");
  }
}

// "List" command
void list_files() {
  for (var name in Directory.current.listSync()) {
    String file_name = name.path.split("\\").last;

    if (file_name.endsWith(".sp")) {
      print(file_name);
    }
  }
}

// "Delete" command
void delete_command(List argv) {
  // if filename is not given...

  if (argv.length == 1) {
    print(chalk
        .red('Provide a filename.\nExample - "sprint delete hello_world"'));
  }

  // Filename is given
  if (argv.length >= 2) {
    File target = File("${Directory.current.path}\\${argv[1]}.sp");

    // File exists
    if (target.existsSync()) {
      target.delete();
      print("Deleted!");
    } else {
      print("Project not found.");
    }
  }
}

// Not a command / filename
void error(name) {
  print(chalk.red('Unknown command: $name'));
}
