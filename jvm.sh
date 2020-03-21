#!/bin/bash

NO_COLOR='\033[31;0m'

logInfo() {
  echo -e "> $1"
}

logError () {
  RED='\e[91m'    # print text in bold red

  echo -e "${RED}> $1${NO_COLOR}"
}

logWarn() {
  YEL='\e[93m'    # print text in bold Yellow

  echo -e "${YEL}> $1${NO_COLOR}"
}

logSuccess() {
  GREEN='\e[92m'
  echo -e "${GREEN}> $1${NO_COLOR}"
}

# TODO: add help...
showHelp () {
  logInfo "Not very helpful, am I?"
}

# Retrieves the current java version accorinding to
# the .java_version file
currentVersion () {
  setJVMHome

  if [ ! -e "$JVM_HOME/.java_version" ]; then
    logError "You have not yet set a java version."
    exit 1
  fi

  JVM_CURRENT_VERSION=`cat "$JVM_HOME/.java_version"`
}

# Prints the java version
printVersion () {
  currentVersion
  logInfo "You are using: $JVM_CURRENT_VERSION"
}

# Sets the JVM home directory to ~/.jvm if it's
# not otherwise specified
setJVMHome () {
  if [ ! $JVM_HOME ]; then
    JVM_HOME="$HOME/.jvm"
    logWarn "JVM_HOME is not set. Defaulting to $JVM_HOME\n"
  fi
}

# Creates the JVM home directory and all it's structure
# if they do not yet exist.
setupJVM () {
  setJVMHome

  mkdir -p $JVM_HOME
  mkdir -p "$JVM_HOME/symlinks/home"
  mkdir -p "$JVM_HOME/symlinks/build"
  mkdir -p "$JVM_HOME/current"

  logSuccess "Setup of JVM complete. Your JVM home directory is: $JVM_HOME"
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

  JVM_SYMLINK_HOME="$JVM_HOME/symlinks/home/$1"
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
  setJVMHome

  if [ ! $1  ]; then
    logError "Version not specified"
    exit 1
  fi

  JVM_SYMLINK_BUILD="$JVM_HOME/symlinks/build/$1"
  if [ ! -e $JVM_SYMLINK_BUILD ]; then
    logError "Version '$1' does not have a java build symlink"
    exit 1
  fi
}

# Updates the current jvm java version
setVersion () {
  VERSION=$1
  if [ ! $VERSION ]; then
    logError "You must specify a version to use"
    exit 1
  fi

  setSymlinkHome $VERSION
  setSymlinkBuild $VERSION

  rm -f "$JVM_HOME/current/java_home"
  cp -P $JVM_SYMLINK_HOME "$JVM_HOME/current/java_home"

  rm -f "$JVM_HOME/current/java"
  cp -P $JVM_SYMLINK_BUILD "$JVM_HOME/current/java"

  echo $VERSION > "$JVM_HOME/.java_version"

  logSuccess "You are now using verison $VERSION"
}

# Registers a new java version with jvm
linkJava () {
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
    logError "The version $VERSION_NAME already exists"
    exit 1
  fi

  setJVMHome
  ln -s $JVM_JAVA_HOME "$JVM_HOME/symlinks/home/$VERSION_NAME"
  ln -s $JVM_JAVA_BUILD "$JVM_HOME/symlinks/build/$VERSION_NAME"

  logSuccess "Added version '$VERSION_NAME'"
}

installVersion () {
  logError "Installation is under construction. You can install a java version yourself, and then register it to JVM using `jvm link`"

  exit 1
}

checkJavaHomeVar () {
  if [ ! $JAVA_HOME ]; then
    logWarn "The JAVA_HOME environment variable is not set. This may cause java version problems with maven. Add \`JAVA_HOME=\$JVM_HOME/current/java_home\` to your shell profile to fix this.\n"
  elif [ $JAVA_HOME != "$JVM_HOME/current/java_home" ]; then
    logWarn "The JAVA_HOME environment variable is set to $JAVA_HOME. This may cause java version problems with maven. Add \`JAVA_HOME=\$JVM_HOME/current/java_home\` to your shell profile to fix this.\n"
  fi
}

###########
# Begin Script

checkJavaHomeVar

ACTION=$1

case $ACTION in
  i | install)
    installVersion $2
  ;;

  v | version)
    printVersion
  ;;

  h | help)
    showHelp
  ;;

  u | use)
    setVersion $2
  ;;

  s | setup)
    setupJVM
  ;;

  l | link)
    linkJava $2 $3
  ;;

  *)
    logError "Unknown action: '$ACTION'\n"
    showHelp
  ;;
esac
