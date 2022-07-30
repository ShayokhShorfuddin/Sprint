
# Sprint
[![Discord](https://img.shields.io/discord/986644057738592317?logo=discord)](https://discord.gg/B6s4MhYYqs)

Sprint is an interpreted, high-level, dynamically typed programming language. It offers a simplistic syntax and the blazing fast compilation speed of Dart at the same time. As it is only v1, there are only a handful amount of things you can do using Sprint but I genuinely wish to upgrade Sprint in each version and make Sprint a complete programming language!


## Get Started
To get started with Sprint, follow the steps below -<br><br>1. Head to https://sprint-pi.vercel.app and download the latest Sprint release.<br><br>![Screenshot 2022-07-30 163131](https://user-images.githubusercontent.com/56217851/181906429-09225a48-b6a8-4c4a-833b-2db4d44389f9.png)<br><br>2. After downloading, copy the path to sprint.exe and add the path into your environmental variables.<br><br>
![Screenshot 2022-07-30 164151](https://user-images.githubusercontent.com/56217851/181906721-e46a3228-c5a4-4917-b733-31dc72b35c25.png)<br><br>3. Fire up your terminal and type "sprint". You should see an ascii resembling *SPRINT*<br><br>![Screenshot 2022-07-30 165321](https://user-images.githubusercontent.com/56217851/181907732-682a73d8-871c-4a4f-9536-2606cc165710.png)<br>

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

## String Interpolation
Use { } to insert data into strings.

```python
target = "John Connor"
print "{target}, come with me if you want to live."

# Output : "John Connor, come with me if you want to live."
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

### Multi-line Comments
```python
"""
This is a comment
This is also a comment
Yet another annoying comment
"""
name = "Peter"
print name
```

## Importing
You can import variables from another files using the ```import``` and ```from``` keywords.<br>
Suppose there are 2 files (main.sp and info.sp) present in your current working directory.<br><br>```info.sp``` file contains 2 variables which are ```name``` and ```age```. You want to import these variables into ```main.sp```.

```dart
// This a also a comment
name = "Peter"
print name
```

## Exiting Execution

Use ```exit``` or ```Exit``` to terminate program execution.
```python
name = "Peter"
exit
print name
# "Peter" will not be printed
```

