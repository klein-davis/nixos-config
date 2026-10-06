_dirbusy() {
  local -a subcmds
  subcmds=(
    'list:show processes/files keeping DIR busy'
    'kill:kill processes keeping DIR busy'
    'unmount:kill blockers then unmount DIR'
  )

  if (( CURRENT == 2 )); then
    _describe 'command' subcmds
    return
  fi

  case ${words[2]} in
    list)
      _arguments \
        '--depth[levels deep to inspect file-by-file]:depth:' \
        '*:directory:_files -/'
      ;;
    kill)
      _arguments \
        '--depth[levels deep to inspect file-by-file]:depth:' \
        '--all[kill every process found, no prompt]' \
        '--pid[kill this pid, no prompt]:pid:' \
        '--signal[signal to send]:signal:(TERM KILL)' \
        {-y,--yes}'[do not ask for confirmation]' \
        '*:directory:_files -/'
      ;;
    unmount)
      _arguments \
        '--depth[levels deep to inspect file-by-file]:depth:' \
        '--lazy[lazy unmount as a last resort]' \
        {-y,--yes}'[do not ask before killing]' \
        '*:directory:_files -/'
      ;;
  esac
}
compdef _dirbusy dirbusy
