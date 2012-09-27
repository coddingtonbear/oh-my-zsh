PROMPT=$'%{$FG[130]%}%n@%m %{$FG[108]%}%D{[%I:%M:%S]} %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%} $(git_prompt_info)$(hg_prompt_info)\
%{$FG[130]%}->%{$FG[108]%} %#%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[224]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$FG[224]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
