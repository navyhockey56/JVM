# JVM
JVM is a very simple script for managing multiple java versions. JVM syncs the version from the `java` command with the version used by your maven through the 'mvn' command. JVM operates by swapping out the symbolic links that your `java` command and `$JAVA_HOME` reference. Currently, JVM is not automated - you must manually create your symbolic links and add new versions to your jvm_config.json.  

## Setup

### JVM_HOME
In order for JVM to work, you will need to create a directory for your 'jvm home' (it can be this project directory if you'd like) and export it as the environment variable JVM_HOME. Your JVM_HOME should be structured as follows:
```
jvm_config.json
symbolic_links/current_java_home
symbolic_links/current_java
symbolic_links/<other_java_versions_home>
symbols_links/<other_java_versions>
```
where `symbolic_links/current_java_home` is a symbolic link pointing to the home directory of the current java version; `symbolic_links/current_java` is a symbolic link pointing to the current java version; `symbolic_links/<other_java_versions_home>` are zero or more symbolic links pointing to other java version home directories; and `symbolic_links/<other_java_version>` are the symbolic links pointing to your other java versions.

You can make your own symbolic links using:
```
ln -s path_to_file_to_point_to/file_to_point_to name_of_symbolic_link_file
```

### jvm_config.json
TODO: explain the structure

### linking your java to JVM
Finally, you will need to create a symbolic link from where your system currently thinks java is to your JVM_HOME's current_java symbolic link. In order to determine where your system thinks java is, simply run:
```
which java
```
in your terminal (often located `/usr/bin`). If no path is returned by `which java`, then you currently do not have a directory on your PATH that contains a java version. If so, you will instead need to create a symbolic link pointing to your JVM_HOME's current_java symbolic link in a location that is on your PATH. 

WARNING: If any of your symbolic links within JVM_HOME point to the path specified by `which java`, then DO NOT do complete the following step! Instead, you will need to update your PATH environment variable to no longer include the path to your java version. Once you've done this successfully. the result of `which java` will return no value; as such, see the above paragraph for instructions on what to do next.

Once you've deduced the location of your java, you will need to overwrite it with a symbolic link pointing to your current_java symbolic link within your JVM_HOME.


### Syncing with Maven
Maven usses the JAVA_HOME environment variable to determine which java version to use, as such, if you wish to keep maven in sync with JVM, you will need to point your JAVA_HOME to your JVM_HOME's current_java_home symbolic link. This can be done with:
```
export JAVA_HOME=$JVM_HOME/symbolic_links/current_java_home
```

## Usage

### Checking your java versions
If you run the script with no input, JVM will output all versions of java it is currently managing, along with which version of java you are currently using.
```
jvm
```

### Changing your java version
To change your java, simply pass the script the version of java you wish to use. For example, to switch to java 8, run:
```
jvm 8
```

