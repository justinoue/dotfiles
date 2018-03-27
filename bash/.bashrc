#
# ~/.bashrc
#

source ~/.bash_aliases

# Local bashrc for contextual settings (work, home, etc)
[[ -f ~/.bashrc_local ]] && . ~/.bashrc_local

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

XDG_CONFIG_HOME="$HOME/.config"
export XDG_CONFIG_HOME

export BROWSER=google-chrome-stable
export EDITOR=vim
export TERM=xterm

export PATH=~/bin:$PATH

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${BRANCH}${STAT}]"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

# Unix epoch time in nanoseconds
function epoch_ms {
  date +%s%3N
}

# Record our start time
function timer_start {
  start_time=${start_time:-$(epoch_ms)}
}

function timer_stop {
  local ms=$(($(epoch_ms) - $start_time))
  local s=$(((ms / 1000) % 60))
  local m=$(((ms / 60000) % 60))
  local h=$((ms / 3600000))
  if ((h > 0)); then timer_show=${h}h${m}m
  elif ((m > 0)); then timer_show=${m}m${s}s
  elif ((s > 10)); then local us=$((${ms} % 10000)); timer_show=${s}.$(printf %03d $us)s
  elif ((s > 0)); then local us=$((${ms} % 1000)); timer_show=${s}.$(printf %03d $us)s
  else timer_show=${ms}ms
  fi
  unset start_time
}

function get_cwd {
  if [ "${PWD}" == "${HOME}" ]; then
    echo "~"
  else
    echo ${PWD/*\//}/
  fi
}

trap 'timer_start' DEBUG
PROMPT_COMMAND=timer_stop

PS1='[\u:$(get_cwd)]$(parse_git_branch)[${timer_show}][${?}]$ '
