# Helpful Dev Scripts

This project is a collection of useful scripts for various dev tasks.
This really is a repository to store things that I use so I don't loose this knowledge.


# Usage

To get access to all scripts from your console source the 'source.sh' script in your .bashrc or .zshrc (or whatever your shell uses...)

Make sure you read these scripts and understand what they do before you blindly follow my instructions. Don't be foolish.

## Dependencies
depending on the scripts you use, you will need different tools

The 'js' scripts are all dependant on having nodejs installed. Tested with version 16. 
No other js dependencies are required by design.

The bash scripts use:
- [yq](https://mikefarah.gitbook.io/yq/) version after 4.18.1
- [jq](https://stedolan.github.io/jq/) version 1.6 or later

## run
A script that generalisizes the runing of projects. 
Because sometimes you forget the run command for specific types of projects when you're switching between languages or frameworks

Currently supports:
- jvm projects (kotlin/java/whatever) with gradle/gradlew springboot or micronaut
- npm projects with a start command
- a project with a docker-compose.yml 

All arguments are passed through to the commands

Logic:
if the script detects a `micronaut-cli.yml` we do one of:
- `gradle run` command (preferencing use of ./gradlew if avaiable)
- `mvn mn:run` command (preferencing use of ./mvnw if avialable)
if theres a pom.xml or build.gradle we fallback to assuming it's a springboot project
- `gradle bootrun` command (preferencing use of ./gradlew if avaiable)
- `mvn spring-boot:run` command (preferencing use of ./mvnw if avaiable)
if therse a package.json assume npm
- `npm start`
if theres a docker-compose.yml
- `docker-compose up`


## build



## test



## jsonToCsv
Convert an array of json objects to a csv list. 

Expectation is for an array of flat objects (i.e. not nested), example:
```
[{ "a": "This is value", "c": "another value"},
{ "a": "different to a", "b": 12, "d": true}]
```
Will output as:
```
"a","b","c","d"
"This is value","","another value",""
"different to a",12,"",true
```

The function reads from stdin so you would pipe your input to the function e.g. 
```
echo '[{ "a": "This is value", "c": "another value"},{ "a": "different to a", "b": 12, "d": true }]' | jsonToCsv
```
or from a file examples:
```
cat file.json | jsonToCsv
jsonToCsv < file.json
```

Trying to use a nested object will result in an error, example:
```
> echo '[{ "a": "This is value", "c": "another value"},{ "a": "different to a", "b": 12, "d": true, "e": {"nested": " a nested value"} }]' | jsonToCsv <aws:development>
"a","b","c","d","e"
"This is value","","another value","",""
> jq: error (at <stdin>:1): object ({"nested":"...) is not valid in a csv row
```

## xmlToJson
Convert an xml document to json. This uses yq to do the conversion. It's really just a shortcut syntax.
```
<example attribute="w" anotherAttribute="z">a
    <aList>
        <item>1</item>
        <item>2</item>
    </aList>
</example>
```

will result in the json:
```
{
  "example": {
    "+content": "a",
    "+attribute": "w",
    "+anotherAttribute": "z",
    "aList": {
      "item": [
        "1",
        "2"
      ]
    }
  }
}
```

The function expects intput from stdin so use standard piping to call the function:
```
echo '<example attribute="w" anotherAttribute="z">a<aList><item>1</item><item>2</item></aList></example>'  | xmlToJson
```
or from a file examples:
```
cat file.xml | | xmlToJson
xmlToJson < file.xml
```

## diffJson
Get a json object that represents the fields that have changed only

Example, with an original object, and an updated version of that object
original:
```
{
  "a": "t",
  "b": {
    "c": "x",
    "d": ["a", "b"],
    "e": {
      "f": "d"
    }
  },
  "w": "x"
}
```
updated:
```
{
  "a": "t",
  "b": {
    "c": "x",
    "d": ["b", "a"],
    "e": {
      "f": "x"
    }
  },
  "x": "w"
}

```

The result will be an object that represents the updates:
```
{ 
  "b": {
    "d": ["b","a"],
    "e":{ 
      "f":"x"
    }
  },
  "w": null,
  "x":"w"
}
```

Using null values to represent where there were values previously but there are no more. This is because we want to see what was removed, and 'null' in json has meaning, over a missing field in context would just mean no change.
We can from the above fairly concisely what has changed, and what it has changed to.


The function is recursive, and will go deep on the object. So be careful with large very JSON structures.


## toLocalDate

Convert a date to your into human readable date/time in the local timezone. Useful when you have a time in one zone or another and you want a quick conversion to your local timezone.

Pass the dates in iso format and you'll be fine. Uses javascript under the covers, so any format that will work in a Date constructor.

Assuming my local timezone is AEDT (UTC +11:00)
```
toLocalDate '2022-01-13T11:40:00Z'
```
Outputs
```
Thu Jan 13 2022 22:40:00 GMT+1100 (Australian Eastern Daylight Time)
```

## toUtcDate

Covert a given zoned/offset date into human readable UTC date/time

Used javascript toUTCString function, so the format varies slightly from above.

example:
```
toUtcDate '2022-01-13T11:40:00+11:00'
```
Outputs
```
Thu, 13 Jan 2022 00:40:00 GMT
```

