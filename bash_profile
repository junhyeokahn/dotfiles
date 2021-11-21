. ~/.bashrc
. ~/.bash_prompt

eval "$(/opt/homebrew/bin/brew shellenv)"

export BASH_SILENCE_DEPRECATION_WARNING=1

export PATH="/opt/homebrew/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup

[[ -z $TMUX ]] || conda deactivate; conda activate base
# <<< conda initialize <<<
