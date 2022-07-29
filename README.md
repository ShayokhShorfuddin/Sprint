# Sprint
[![Discord](https://img.shields.io/discord/986644057738592317)](https://discord.gg/B6s4MhYYqs)

Sprint is an interpreted, high-level, dynamically typed programming language. It offers a simplistic syntax and the blazing fast compilation speed of Dart at the same time. As it is only v1, there are only a handful amount of things you can do using Sprint but I genuinely wish to upgrade Sprint in each version and make Sprint a complete programming language!

## Syntax
The syntax is quite simple. If you want to use ```;``` at the end of each line, that's absolutely fine! Sprint won't cause any issue if do or don't put ```;``` at the end of each line. Extra spaces at the start and the end of each line are trimmed and empty lines are simply ignored. You can use comments in your code by adding ```#``` or ```//``` at the start of a line. Now, let's talk about Exceptions in Sprint. Sprint tries to keep Expections as much clear as possible so that debugging can be easier. Also, I added a feature in the ```VariableNotFound``` error called "Variable Suggestor". Suppose you defined a variable ```weather = "Cloudy";``` and then you wanted to print it by writing ```print weathar;``` but Sprint will throw a ```VariableNotFound``` error. After throwing the error, Sprint will also say ```Did you mean weather?```

Finally, here are all the available things you can perform using Sprint - 

## Print
```python
print "Hello world!"
```
Newline charecter ```\n``` is also supported.
```python
print "Hello\nworld!"
# Output: Hello
# world!
```

## Define Variables
```python
name = "Peter"
print name
```

## Updating Variables
```python
a = "foo"
b = "bar"
a = b
print a

# Output will be "bar"
```

## Mathmatical Operations
For performing math, Sprint uses function_tree 0.8.13 package. Feel free to take a look at it here: https://pub.dev/packages/function_tree
```python
math = 2 + 2
print math
# Output: 4.0

math = (3 + 2)^3
print math
# Output: 125.0

math = 3 * sin(5 * pi / 6)
print math
# Output: 1.5000000000000009
```


## Comments
You can use ```#``` or ```//``` for commenting. It's totally upto you.
```python
# This is a comment
name = "Peter"
print name
```

```dart
// This a also a comment
name = "Peter"
print name
```

**Warning**: Comments at the end of a line containing code is not supported yet.
```python
name = "Peter"  # This is a comment
print name
```
This will cause an error. I hope to resolve this issue in future updates.


## Exiting Execution
Use ```exit``` or ```Exit``` to terminate program execution.
```python
name = "Peter"
exit
print name
# "Peter" will not be printed
```

