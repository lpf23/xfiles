_sourceFiles_() {
  filesToSource=(
    "${HOME}/xfiles/scripting/helpers/baseHelpers.bash"
    "${HOME}/xfiles/scripting/helpers/files.bash"
    "${HOME}/xfiles/scripting/helpers/textProcessing.bash"
    "${HOME}/xfiles/scripting/helpers/numbers.bash"
  )

  for sourceFile in "${filesToSource[@]}"; do
    [ ! -f "$sourceFile" ] \
      && { echo "error: Can not find sourcefile '$sourceFile'"; }
    source "$sourceFile"
  done

  # Set default usage flags
  quiet=false
  printLog=false
  logErrors=false
  verbose=false
  dryrun=false
  force=false

}
_sourceFiles_