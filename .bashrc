# User dependent .bashrc file

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Environment variables
export EDITOR='vim'

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUPSTREAM=1
export GIT_PS1_SHOWUNTRACKEDFILES=
export GIT_PS1_SHOWSTASHSTATE=1

export LESS='-iRFX -# 5'

# Load git completion
## for windows
if [ "$(uname -o)" = "Msys" ]; then
    source /usr/share/git/completion/git-prompt.sh
    source /usr/share/git/completion/git-completion.bash
    GIT_PS1_SHOWDIRTYSTATE=true
## for ubuntu
elif [ "$(uname)" = "Linux" ]; then
    source /etc/bash_completion.d/git-prompt
    GIT_PS1_SHOWDIRTYSTATE=true
## for mac
elif [ "$(uname)" = "Darwin" ]; then
    source /usr/local/etc/bash_completion.d/git-prompt.sh
    source /usr/local/etc/bash_completion.d/git-completion.bash
    GIT_PS1_SHOWDIRTYSTATE=true
fi

## Shorten dirname
export PROMPT_DIRTRIM=4


# Shell Options
#
# See man bash for more options...
#
# Don't wait for job termination notification
# set -o notify
#
# Don't use ^D to exit
set -o ignoreeof
#
# Use case-insensitive filename globbing
# shopt -s nocaseglob
#
# Make bash append rather than overwrite the history on disk
shopt -s histappend
#
# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
# shopt -s cdspell
#
# Don't stop stty with ^s
stty stop undef

# Completion options
#
# These completion tuning parameters change the default behavior of bash_completion:
#
# Define to access remotely checked-out files over passwordless ssh for CVS
# COMP_CVS_REMOTE=1
#
# Define to avoid stripping description in --option=description of './configure --help'
# COMP_CONFIGURE_HINTS=1
#
# Define to avoid flattening internal contents of tar files
# COMP_TAR_INTERNAL_PATHS=1
#
# Load bash_completion if it exists
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
elif [ -f /usr/local/etc/bash_completion ]; then
    source /usr/local/etc/bash_completion
elif [ -f /usr/local/share/bash-completion/bash_completion ]; then
    source /usr/local/share/bash-completion/bash_completion
fi

# My completion
if type -p git-manage > /dev/null; then
    _git_manage()
    {
        local word="${COMP_WORDS[COMP_CWORD]}"
        if [ $COMP_CWORD -lt 3 ]; then
            COMPREPLY=($(compgen -W "add remove ls lookover" -- "$word"))
        fi
    }
    complete -F _git_manage git-manage
fi

# History Options
#
# Don't put duplicate lines in the history.
# export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well
#
# Whenever displaying the prompt, write the previous line to disk
export PROMPT_COMMAND="history -a;${PROMPT_COMMAND}"

# Functions
#
if [ "$(uname)" = "Darwin" ]; then
    emacs_gui=/Applications/Emacs.app/Contents/MacOS/Emacs
else
    emacs_gui=emacs
fi
function emacs () {
    emacsclient "$@" >& /dev/null || $(${emacs_gui} "$@")
}
function less_table () {
    column -t "$1" | sed '/^\s*#/ s/ \{1,\}/ /g' | less
}
function unlink_files () {
    for f in "$@"
    do
        unlink $f
    done
}
function show_path () {
    echo $PATH | tr ":" "\n"
}

function terminal_device_type() {
    tty | perl -pe 's|/dev/([^/0-9]+)/?.*|\1|'
}
TERM_TYPE=$(terminal_device_type)

# Detect session type
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    SESSION_TYPE=remote/ssh
fi

# Settings for iTerm2 window name and tab name
function tab-color() {
    echo -ne "\033]6;1;bg;red;brightness;$1\a"
    echo -ne "\033]6;1;bg;green;brightness;$2\a"
    echo -ne "\033]6;1;bg;blue;brightness;$3\a"
}
function tab-reset() {
    echo -ne "\033]6;1;bg;*;default\a"
}
function change_window_title() {
    local cdir=$(pwd | sed -e "s|$HOME|~|")
    echo -ne "\033]2;$cdir\007" # window title
}
export PROMPT_COMMAND="change_window_title;${PROMPT_COMMAND}"
function change_tab_title() {
    local host_name=$(hostname | sed "s/\.local$//")
    local user_name=$(whoami)
    if [[ $SESSION_TYPE = remote/ssh ]]; then
        echo -ne "\033]1;$(whoami)@${host_name}\007"
    else
        echo -ne "\033]1;$(whoami)@${host_name}\007"
    fi
}
# Change tab title when starting bash
# change_tab_title
# Change tab title when returning back to local
# function ssh() { command ssh "$@"; change_tab_title; }

# PS1
## Red='\[\e[31m\]'
## Green='\[\e[32m\]'
## Yellow='\[\e[33m\]'
## Blue='\[\e[34m\]'
## Purple='\[\e[35m\]'
## Cyan='\[\e[36m\]'
## White='\[\e[37m\]'
## Reset='\[\e[0m\]'
case "$TERM" in
    "dumb")
        PS1="> "
        ;;
    xterm*|rxvt*|eterm*|screen*)
        if type -p __git_ps1; then
            # For remote
            if [[ $SESSION_TYPE = remote/ssh ]]; then
                export PS1='\[\e[32;1m\]\u@\[\e[0m\]\[\e[33;1m\]\h\[\e[0m\]: \[\e[34;1m\]\w\[\e[0m\]\[\e[35m\]$(__git_ps1)\[\e[0m\]'$'\n\$ '
            # For local
            else
                export PS1='\[\e[32;1m\]\u@\h\[\e[0m\]: \[\e[34;1m\]\w\[\e[0m\]\[\e[35m\]$(__git_ps1)\[\e[0m\]'$'\n\$ '
            fi
        else
            # For remote
            if [[ $SESSION_TYPE = remote/ssh ]]; then
                export PS1='\[\e[32;1m\]\u@\[\e[0m\]\[\e[33;1m\]\h\[\e[0m\]: \[\e[34;1m\]\w\[\e[0m\]'$'\n\$ '
            # For local
            else
                export PS1='\[\e[32;1m\]\u@\h\[\e[0m\]: \[\e[34;1m\]\w\[\e[0m\]'$'\n\$ '
            fi
        fi
        ;;
    *)
        PS1="> "
        ;;
esac

# Aliases
#
# Load different file for aliases
if [ -f "${HOME}/.bash_aliases" ]; then
  source "${HOME}/.bash_aliases"
fi
#
# Launch vanilla bash
alias bashq='env -i bash --norc --noprofile'
#
# Interactive operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias cdh='cd ~'
#
# Default to human readable figures
alias df='df -h'
alias du='du -h'
#
# Misc
alias m='\less +F'
# alias whence='type -a'                        # where, of a sort
alias grep='grep -i --color'                     # show differences in colour
# alias egrep='egrep --color=auto'              # show differences in colour
# alias fgrep='fgrep --color=auto'              # show differences in colour
#
# Some shortcuts for different directory listings
alias ls='ls -hF --color=tty --group-directories-first'    # classify files in colour
# alias dir='ls --color=auto --format=vertical'
# alias vdir='ls --color=auto --format=long'
alias ll='ls -l'                              # long list
alias la='ls -A'                              # all but . and ..
alias lly='ls -l --time-style=long-iso'
# alias l='ls -CF'

# Applications
alias tree='tree --dirsfirst -C'
alias pyman='python -m pydoc'
alias lesst='less_table'
alias tiga='tig --all'
alias gg='git graph'
alias gu='git remote update'
alias jn='jupyter notebook &> /dev/null &'
alias v='view -M'

if [ `type -p colordiff` ]; then
    alias diff='colordiff -u'
else
    alias diff='diff -u'
fi

# The alias for tmux doesn't work on windows msys2
if [ "$(uname)" = "Linux" ] && [ `type -p direnv` ]; then
    alias tmux='direnv exec / tmux'
fi

# aliases and functions for linux
if [ "$(uname)" = "Linux" ]; then
    alias emacs='XMODIFIERS=@im=none emacs'
fi

if [ "$(uname)" = "Darwin" ]; then
    alias airport=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport
fi

# aliases and functions for windows
if [ "$(uname -o)" = "Msys" ]; then
    function trash () {
        winpty gomi "$@"
    }
    alias inkscape='PYTHONPATH= inkscape'
    alias sumatrapdf='sumatrapdf -reuse-instance'
    # function to build cython
    function cython_build_mingw () {
        python $1 build_ext -i --compiler=mingw32 -DMS_WIN64
    }
    #alias ipconfig='winpty ipconfig'
    function ipconfig () {
        command ipconfig "$@" | nkf -w
    }
    # alias ping='winpty ping'
    function ping () {
        command ping "$@" | nkf -wu
    }
    # alias netstat='winpty netstat'
    function netstat () {
        command netstat "$@" | nkf -w
    }
    # alias netsh='winpty netsh'
    function netsh () {
        command netsh "$@" | nkf -wu
    }
    # alias cscript='winpty cscript'
    function cscript () {
        command cscript "$@" | nkf -wu
    }
    #alias tracert='winpty tracert'
    function tracert () {
        command tracert "$@" | nkf -wu
    }
    alias taskkill='winpty taskkill'
    function tasklist () {
        command tasklist "$@" | nkf -wu
    }
    alias pshell='winpty powershell'
    alias ipython='winpty ipython'
    alias cmd='winpty cmd'
fi

# dircolors
if [ -f "${HOME}/.dircolors" ]; then
    eval `dircolors ${HOME}/.dircolors`
fi

# direnv
if [ `type -p direnv` ]; then
    eval "$(direnv hook bash)"
fi

# fzf
if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
fi
if [ `type -p fzf` ]; then
   # cd to selected directory including hidden ones
   function cdd() {
       local dir
       dir=$(find ${1:-.} -type d -maxdepth ${2:-1} 2> /dev/null | fzf +m) && cd "$dir"
   }
   # change directory to a directory in which target file exists
   function cdf() {
       local file
       local dir
       file=$(fzf --height 30% --reverse +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
   }
   # command history search
   function _search_history() {
       local cmd
       cmd=$( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) |
              perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\s*//; $in=$_;
                        if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' |
              fzf --height 30% --reverse +s --tac | sed 's/ *[0-9]* *//')
       [[ -z $cmd ]] && return
       READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$cmd${READLINE_LINE:$READLINE_POINT}"
       READLINE_POINT=$(( READLINE_POINT + ${#cmd} ))
   }
   bind -x '"\C-r": _search_history'
   function mynote-search() {
       local file
       local pager
       file=$(ag --markdown --nonumber --nogroup "keywords:" ~/my-note | fzf --height 30% --reverse -q ${@:-""} | perl -pe 's/(.*?):.*/$1/g')
       # Exit when canceled
       [[ -z $file ]] && return
       #
       if [ `type -p view ` ]; then
           pager='view -M'
       else
           pager='less'
       fi
       ${pager} ${file}
   }
   function _search_oneliner() {
       local file
       local cmd
       file=~/.oneliner
       cmd=$( cat $file | fzf --height 30% --reverse | perl -pe 's/^\[[^\]]+\]\s*//g' )
       # Exit if canceled
       [[ -z $cmd ]] && return
       #
       if [ ${cmd:$((${#cmd}-1))} = "!" ]; then
           cmd=$(echo ${cmd} | sed 's/!$//')
           eval ${cmd}
       else
           READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$cmd${READLINE_LINE:$READLINE_POINT}"
           READLINE_POINT=$(( READLINE_POINT + ${#cmd} ))
       fi
   }
   bind -x '"\C-s": "_search_oneliner"'
fi

# enhancd
if [ -f ~/repos/enhancd/init.sh ]; then
    source ~/repos/enhancd/init.sh
    export ENHANCD_FILTER=fzf:peco:gof
fi

# Key bindings
# Menu completion
# bind "C-j":menu-complete
