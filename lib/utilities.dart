// This file contains utility functions that will help us while coding.

// Get runtime type
import 'dart:ffi';

// Length
int len(object) {
  return object.length;
}

// Counting the presence of a char in string
int count(search_for, object) {
  return search_for.allMatches(object).length;
}

// Remove the last char of a string
String removeLast(object) {
  return object.substring(0, object.length - 1);
}

// Convert to integer
int integer(object) {
  return int.parse(object);
}

// Convert to float
double float(object) {
  return double.parse(object);
}
