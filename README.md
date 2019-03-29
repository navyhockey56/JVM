# JVM
JVM is a very simple script for managing multiple java versions. JVM syncs the version from the `java` command with the version used by your maven through the 'mvn' command. JVM operates by swapping out the symbolic links that your `java` command and `$JAVA_HOME` reference. Currently, JVM is not automated - you must manually create your symbolic links and add new versions to your jvm_config.json.  

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
