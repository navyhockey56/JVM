# JVM
JVM is a very simple script for managing multiple java versions through the use of symbolic links. JVM allows you to select and switch between java versions with a single command. Furthermore, JVM manages your `$JAVA_HOME` environment variable, thus keeping other tools such as Maven in-sync with the changes to your java version.

## Installation
You can install JVM by cloning this project locally (https://github.com/navyhockey56/JVM).

### Adding JVM to your $PATH
Once you have the project installed, either copy the `jvm` script to a directory on your `$PATH`, or append the JVM project's directory to your `$PATH`.

### Initializing JVM
In order for the java version JVM is using to coordinate with maven, JVM will need to be initialized for each session of your user. To initialize JVM, simply source the `init` command in your shell's profile:
```bash
# If you are adding the JVM script to your $PATH directly, you must
# do so prior to running the `init` command
PATH=$PATH:/path/to/jvm/clone/JVM

# Initialize JVM
source jvm init
```

### Using a different JVM Home Directory
By default, JVM will use `~/.jvm` as it's home directory for storing the symbolic links to java verisons. However, this can be overriden by specifying a different directory using the `$JVM_HOME` environment variable. Simply specify the directory in your shell's profile.
```bash
# This must be specified prior to initializing JVM!
JVM_HOME=/some/other/path/to/keep/jvm
# Initialize the JVM environment
source jvm init
```

## Usage
JVM provides a simple interface for managing your java versions. All commands are of the form:
```bash
jvm <command> [<args>]
```

### View Help
JVM has a `help` command for providing both general information as well as information about a specific command.
```bash
# General help
jvm help

# Help about a command
jvm help <command>
```

### Check Java Version
JVM sets a single, global java version. You can use the `version` command to determine which version of java JVM is currently using.
```bash
# Check the version you are currently using
jvm version

# Lists all java versions JVM is managing
jvm version -l
```

### Add Java Version
JVM does not (currently) have the ability to install java versions for you. However, one you install a java version onto your computer, you will be able to add it to JVM with the `link` command. Simply tell jvm the path to the java version's home directory, and what you would like to name the version.
```bash
jvm link </path/to/java/version/home/directory> <name>
```

### Change Java Version
JVM sets a single, global java version. You can use the `use` command to switch between versions
```bash
# Tell jvm to use a different version
jvm use <version>

# Example of telling jvm to use 'java8'
jvm use java8
```
