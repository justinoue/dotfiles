# Source fish git prompt functions if it exists
for f in $fish_function_path/__fish_git_prompt.fish
    test -e $f; and source $f; and break
end

set __fish_git_prompt_char_stagedstate "s"
set __fish_git_prompt_char_dirtystate "d"
set __fish_git_prompt_char_untrackedfiles "u"
set __fish_git_prompt_char_conflictedstate "c"
set __fish_git_prompt_char_cleanstate "C"

set __fish_git_prompt_color_branch green --bold

function in_git_status
  if string match -q -- "*$argv[1]*" (__fish_git_prompt_informative_status)
    return 0
  end
  return 1
end

function git_is_repo -d "Check if directory is a repository"
  test -d .git; or command git rev-parse --git-dir >/dev/null 2> /dev/null
end

function set_git_color --on-event fish_prompt
  if git_is_repo
    if in_git_status C         # Clean
      set __fish_git_prompt_color_branch green --bold
    else if in_git_status d    # Dirty
      set __fish_git_prompt_color_branch red --bold
    else if in_git_status c    # Conflicted
      set __fish_git_prompt_color_branch yellow --bold
    else if in_git_status u    # Untracked
      set __fish_git_prompt_color_branch red
    else if in_git_status s    # Staged
      set __fish_git_prompt_color_branch purple
    end
  end
end
