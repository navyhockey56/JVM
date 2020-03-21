#!/bin/bash

########################################################
# Logging Functions

# Removes color from echo statements
NO_COLOR='\033[31;0m'

if [ "$1" = "init" ]; then
  LOG_ERROR_ONLY="true"
else
  LOG_ERROR_ONLY="false"
fi

logInfo() {
  if [ "$LOG_ERROR_ONLY" = "false" ]; then
    echo -e "> $1"
  fi
}

logError () {
  RED='\e[91m'

  echo -e "${RED}> $1${NO_COLOR}"
}

logWarn() {
  YEL='\e[93m'

  if [ "$LOG_ERROR_ONLY" = "false" ]; then
    echo -e "${YEL}> $1${NO_COLOR}"
  fi
}

logSuccess() {
  GREEN='\e[92m'
  if [ "$LOG_ERROR_ONLY" = "false" ]; then
    echo -e "${GREEN}> $1${NO_COLOR}"
  fi
}


########################################################
# Help Info

showInstallHelp () {
  echo "JVM Help: install

  Description:
    Installs the specified version of java.

  Usages:
    jvm install <version>
    jvm i <version>

    Args:
      <version> The name of the java version to use
"
}

showVersionHelp () {
  echo "JVM Help: version

  Description:
    Specifies the current version of java JVM is using.

  Usages:
    jvm version
    jvm v
"
}

showUseHelp () {
  echo "JVM Help: use

  Description:
    Switches JVM to use the specified java version

  Usages:
    jvm use <version>
    jvm u <version>

    Args:
      <version> The name of the java version to use
"
}

showSetupHelp () {
  echo "JVM Help: setup

  Description:
    Creates the JVM home directory and related folders if they do not exist.

  Usages:
    jvm setup
    jvm s
"
}

showLinkHelp () {
  echo "JVM Help: link

  Description:
    Adds an installed java version to JVM

  Usages:
    jvm link <java_home> <version>
    jvm link <java_home> <version>

    Args:
      <java_home> The path to the home directory of the java version to add a link to
      <version>   coWhat you want to name the java version
"
}

showInitHelp () {
  echo "JVM Help: init

  Description:
    Initializes JVM.

  Usages:
    Add 'eval \"source jvm init\"' to your shell profile.
"
}

showGeneralHelp () {
  echo "JVM Help

  Description:
    Information on how to use JVM.

  Usage:
    jvm <command> [<args>]

  Commands:
    install      Installs a java version
    version      Output the current java version
    link         Adds a reference to a installed java version
    init         Initialize JVM
    setup        Sets up your JVM home directory
    help         Displays helpful information about JVM

  JVM Help Command:
    Description:
      Displays the information you are currently viewing or information about a specific command.

    Usages:
      jvm help
      jvm h
      jvm help <command>
      jvm h <c>

      Args:
        <command> Provides information about the command when supplied.
"
}

# Display help information
showHelp () {

  case $1 in
    i | install)
      showInstallHelp
    ;;

    v | version)
      showVersionHelp
    ;;

    u | use)
      showUseHelp
    ;;

    s | setup)
      showSetupHelp
    ;;

    l | link)
      showLinkHelp
    ;;

    init)
      showInitHelp
    ;;

    *)
      showGeneralHelp
    ;;
  esac
}

########################################################
# Setters

# Sets the JVM home directory to ~/.jvm if it's
# not otherwise specified
setJVMHome () {
  if [ ! $JVM_HOME ]; then
    export JVM_HOME="$HOME/.jvm"
    logWarn "JVM_HOME is not set. Defaulting to $JVM_HOME\n"
  fi
}

setJVMVersionFile () {
  JVM_VERSION_FILE="$JVM_HOME/.java_version"
}

# Retrieves the current java version accorinding to
# the .java_version file
setCurrentJavaVersion () {
  if [ ! -e $JVM_VERISON_FILE ]; then
    logError "You have not yet set a java version."
    exit 1
  fi

  JVM_CURRENT_VERSION=`cat "$JVM_HOME/.java_version"`
}


setSymlinksHomeDir () {
  JVM_SYMLINK_HOME_DIR="$JVM_HOME/symlinks/home"
}

setSymlinksBuildDir () {
  JVM_SYMLINK_BUILD_DIR="$JVM_HOME/symlinks/build"
}

setSymlinksCurrentDir () {
  JVM_SYMLINK_CURRENT_DIR="$JVM_HOME/current"
}

# Sets the $JVM_SYMLINK_HOME variable to the path to the
# specified java version's home symlink.
#
# @param The java version (name of home symlink)
setSymlinkHome() {
  setJVMHome

  if [ ! $1  ]; then
    logError "Version not specified"
    exit 1
  fi

  JVM_SYMLINK_HOME="$JVM_SYMLINK_HOME_DIR/$1"
  if [ ! -e $JVM_SYMLINK_HOME ]; then
    logError "Version '$1' does not have a java home symlink"
    exit 1
  fi
}

# Sets the $JVM_SYMLINK_BUILD variable to the path to the
# specified java version's build symlink.
#
# @param The java version (name of build symlink)
setSymlinkBuild() {
  if [ ! $1  ]; then
    logError "Version not specified"
    exit 1
  fi

  JVM_SYMLINK_BUILD="$JVM_SYMLINK_BUILD_DIR/$1"
  if [ ! -e $JVM_SYMLINK_BUILD ]; then
    logError "Version '$1' does not have a java build symlink"
    exit 1
  fi
}

setJavaHome () {
  export JAVA_HOME="$JVM_SYMLINK_CURRENT_DIR/java_home"
}

########################################################
# Actions

# Prints the java version
printJavaVersion () {
  setCurrentJavaVersion
  logInfo "You are using: $JVM_CURRENT_VERSION"
}


# Creates the JVM home directory and all it's structure
# if they do not yet exist.
setupJVM () {
  mkdir -p $JVM_HOME
  mkdir -p $JVM_SYMLINK_HOME_DIR
  mkdir -p $JVM_SYMLINK_BUILD_DIR
  mkdir -p $JVM_SYMLINK_CURRENT_DIR

  logSuccess "Setup of JVM complete. Your JVM home directory is: $JVM_HOME"
}


# Updates the current jvm java version in use
useJavaVersion () {
  VERSION=$1
  if [ ! $VERSION ]; then
    logError "You must specify a version to use"
    exit 1
  fi

  setSymlinkHome $VERSION
  setSymlinkBuild $VERSION

  rm -f "$JVM_SYMLINK_CURRENT_DIR/java_home"
  cp -P $JVM_SYMLINK_HOME "$JVM_HOME/current/java_home"

  rm -f "$JVM_SYMLINK_CURRENT_DIR/java"
  cp -P $JVM_SYMLINK_BUILD "$JVM_HOME/current/java"

  echo $VERSION > "$JVM_HOME/.java_version"

  logSuccess "You are now using verison $VERSION"
}

# Registers a new java version with jvm
linkJavaVersion () {
  JVM_JAVA_HOME=$1
  if [ ! -d $JVM_JAVA_HOME ]; then
    logError "$JVM_JAVA_HOME is not a directory"
    exit 1
  fi

  JVM_JAVA_BUILD="$JVM_JAVA_HOME/bin/java"
  if [ ! -e $JVM_JAVA_BUILD ]; then
    logError "Expected to find java at: $JVM_JAVA_BUILD"
    exit 1
  fi

  VERSION_NAME=$2
  if [ ! $VERSION_NAME ]; then
    logError "You must specify a name for this version"
    exit 1
  fi

  if [ -e $VERSION_NAME ]; then
    logError "The version '$VERSION_NAME' already exists"
    exit 1
  fi

  setJVMHome
  ln -s $JVM_JAVA_HOME "$JVM_SYMLINK_HOME_DIR/$VERSION_NAME"
  ln -s $JVM_JAVA_BUILD "$JVM_SYMLINK_BUILD_DIR/$VERSION_NAME"

  logSuccess "Added version '$VERSION_NAME'"
}

installJavaVersion () {
  logError "Installation is under construction. You can install a java version yourself, and then register it to JVM using `jvm link`"

  exit 1
}

########################################################
# Initialization of JVM

# Warns users if their JAVA_HOME is misconfigured
checkJavaHomeVar () {
  if [ ! $JAVA_HOME ]; then
    logWarn "The JAVA_HOME environment variable is not set. Add 'eval \"source jvm init\"' to your shell profile to fix this.\n"
  elif [ $JAVA_HOME != "$JVM_SYMLINK_CURRENT_DIR/java_home" ]; then
    logWarn "The JAVA_HOME environment variable is set to $JAVA_HOME. This may cause java version problems with maven. Add 'eval \"source jvm init\"' to your shell profile. to fix this.\n"
  fi
}

addJavaToPath () {
  JVM_PATH_ENTRY=`echo $PATH | tr ':' '\n' | grep "$JVM_SYMLINK_CURRENT_DIR"`
  if [ ! $JVM_PATH_ENTRY ]; then
    PATH="$JVM_SYMLINK_CURRENT_DIR:$PATH"
  fi
}

# Initializes all the variables need to perform the actions.
initJVM() {
  # Set all the variables
  setJVMHome
  setJVMVersionFile
  setSymlinksHomeDir
  setSymlinksBuildDir
  setSymlinksCurrentDir

  # Set the JAVA_HOME & PATH when `jvm init` is explicitly called
  if [ "$1" = "init" ]; then
    # Save the JAVA_HOME variable for maven
    setJavaHome

    addJavaToPath

    # Create JVM directories if they don't yet exist
    setupJVM
  fi

  # Check if JAVA_HOME is configured correctly.
  checkJavaHomeVar
}

########################################################
# Begin Script

# The user's action should always be the first arg
ACTION=$1

# Initialize JVM
initJVM $ACTION

# Perform the requested action
case $ACTION in
  i | install)
    installJavaVersion $2
  ;;

  v | version)
    printJavaVersion
  ;;

  h | help)
    showHelp $2
  ;;

  u | use)
    useJavaVersion $2
  ;;

  s | setup)
    setupJVM
  ;;

  l | link)
    linkJavaVersion $2 $3
  ;;

  init)
    # Already initialized
  ;;

  *)
    logError "Unknown action '$ACTION'\n"
    showHelp
  ;;
esac
