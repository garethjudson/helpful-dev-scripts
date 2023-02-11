# Helpful Dev Scripts
This project is a collection of useful scripts for various dev tasks.
In some cases the scripts may be just a wrapper around a command, and by itself not be that valuable. 
As this really is a repository to store things that I use (or have used) so I don't loose this knowledge.  


I find it is often a useful way for me to learn and retain knowledge to write code using a tool, or technique so that I can remember how to do it later.
So if I don't remember directly I have this project to refer to, so that it will refresh my knowledge.

## Usage
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
Supports gradle and maven, preferencing wrappers. Forwards arguments to function calls.

examples:

`./gradlew clean build`

`./mvnw clean install`

## test
Supports npm, gradle and maven, preferencing wrappers. Forwards arguments to function calls.

examples:

`npm test`

`./gradlew test`

`./mvnw test`

# nextSemanticVersion
Just a script to take a recommended version bump and apply it to your semantic version.
Useful in conjunction with conventional commits.
An example would be to use in conjunction with npm project conventional-recommended-bump, which will tell you 'patch', 'minor' and 'major' based on your commit history (e.g. conventional-changelog-angular)


This means you don't have to use something that is packaging or build tool specific, so you can potentially apply to all projects and just bundle the build tools into the build agent (or preferably, imo, docker image)

Usage:
 `next_semantic_version 1.0.0 patch' result 1.0.1

 `next_semantic_version 1.0.2 minor' result 1.1.0

 `next_semantic_version 1.2.4 major' result 2.0.0

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
cat file.xml | xmlToJson
xmlToJson < file.xml
```

## diffDirs
Compare the contents of two directory trees and get the differences.
Does not compare files, just the existence or non-existence of files. 

Undercovers this uses 'diff' for the output so it can be interpretted the same way. 

e.g 
Directory structure:
```
a -> c/
     -> fileOne.json
  -> d/ 
     -> fileTwo.xml
  -> f/

b -> c/ 
     -> fileTwo.json
     -> fileTwoA.json
  -> d/
     -> fileTwo.xml
  -> f/
     -> fileThree.json
``` 
Then using the utility:
```
> diffDirs a b

1,2c1
< /c/fileOne.json
< /c/fileTwoA.json
---
> /c/fileTwo.json
3a3
> /f/fileThree.json
```

If you only want to see if files are added/missing etc. this is useful

## hsi
This is just an alias for `history | grep -i` 
This is useful when you want to search for a previous command, maybe with a pattern or otherwise thats a bit more vague than what you might find in the reverse search (e.g. ctrl+r). It also allows you to pipe the output to further commands or by passing to grep again e.g. if you want to do a -v inverse match, this means you find things when you're really fuzzy about specifics or if you run a command a lot with complex arguments and want a specific example.

Example:
`hsi 'diffDirs . b'`

```
50* diffDirs a b
51* diffDirs c b
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

## diffSync
Utility that will sync directories, from or to s3, or locally. The build in aws sync relies on filesize and modified date to determine when to sync files. This is for when you acutally need to know if the file has changed. THIS UTILITY WILL DELETE FILES FROM THE DESTINATION 'to' DIRECTORY/BUCKET. Use at your own risk.


Sometimes sending events into s3 because you overwritten a file that hasn't changed is not wanted. Sometimes filesize does not change but the file has changed. In some circumstances the last modified dates will not be the same, when the files have not changed. The soluntion is to sync the bucket to an empty temporary directory and then compare this to the local directory. This is not intended for buckets that are huge, use at your own risk of waiting forever! 


supported usage:
`diffSync 'from' 'to'`

all files in the from directory will be synced (including deleting missing files from the 'to' directory)

Local directories:
`diffSync "./local/dir/a" "./local/dir/b"`

From local to s3:
`diffSync "./local/dir/a" "s3://remote_bucket/key/prefix/to/logical/dirs/here/"`

From s3 to local:
`diffSync "s3://remote_bucket/key/prefix/to/logical/dirs/here/" "./local/dir/a"`


You manage how you log into the s3 command line. If you don't know how to do this safely and securely, then you shouldn't use this utility.

## dump_db
dump_db is a function that wraps database dump commands and outputs the dump to stdout. 

The command uses network compression, but manually gzip compresses the output when writing the stream. 

You can then pipe that output to disk, the cloud or whereever you feel like.


*Note:*
  look at dump_db and understand how it works. Using this incorrectly could leak passwords and data. This could present a security risk.
  
  If you don't understand the risk of using this function, probably don't. Ask yourself what you're doing with your life :D 
  
  HIGHLY recommend testing this on a test DB that does not matter before you do anything silly with it.
  TODO: implement validation of inputs.


example usage:
```
  dump_db -t "mysql" -h "myhost" -u "myuser" -p "fakepassword" > mysql_dump_file.gz
```

or

```
  dump_db -t "mysql" -h "myhost" -u "myuser" -p "fakepassword" | special_command_to_put_the_output_somewhere
```

required options:
```
  -t --db_type       the database type (currently supported 'mysql' and 'postgres')
  -h --db_host       the database host
  -n --db_name       the name of the database to dump
  -u --db_user       username on the database server that is allowed to do a dump
  -P --db_password   password of the user (there is inherant security risk providing a database password through a command line. Understand the risk and use this tool with caution!!)
```
other options:
```
  -p --db_port       the database port (mysql default = 3306, postgres default = 5432)
```

## restore_db
restore_db is a function that wraps database restore commands and restores a gziped dump to the appropriate database.

It reads the dump from stdin, so you can supply it from the command line from whereever you choose. 
Supports mysql and postgres via the mysql cli and pg_restore tool.


*Note:*
  Understand how this works. Using this incorrectly could result in data loss. Passwords are passed around and this could present a security risk.
  
  If you don't understand the risk of using this function, probably don't. Ask yourself what you're doing with your life :D 
  
  HIGHLY recommend testing this on a test DB that you can afford to overwrite before you do anything silly with it.
  
  TODO: implement validation of inputs.

example usage: 
```
  cat mysql_dump_file.gz | restore_db -t "mysql" -h "myhost" -u "myuser" -p "fakepassword"
```

or 
```
  restore_db -t "mysql" -h "myhost" -u "myuser" -p "fakepassword" < mysql_dump_file.gz
```

required options:
```
  -t --db_type       the database type (currently supported 'mysql' and 'postgres')
  -h --db_host       the database host
  -n --db_name       the name of the database to dump
  -u --db_user       username on the database server that is allowed to do a dump
  -P --db_password   password of the user (there is inherant security risk providing a database password through a command line. Understand the risk and use this tool with caution!!)
```

other options:
```
  -p --db_port       the database port (mysql default = 3306, postgres default = 5432)
```

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
