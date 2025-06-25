
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_CLEAN=""

function prompt_char {
	if [ $UID -eq 0 ]; then echo "%{$fg[red]%}#%{$reset_color%}"; else echo $; fi
}

function display_tw_tags() {
    local tw_output

    # Execute the command and capture its output.
    # We use 2>/dev/null to suppress any errors from `tw` or `jq`
    # (e.g., if `tw` isn't found, or if `dom.active.json` doesn't exist,
    # or if `jq` fails because the input isn't valid JSON).
    tw_output=$(tw get dom.active.json 2>/dev/null | jq -r '.tags | join("|")' 2>/dev/null)

    # Check if the output, after removing all whitespace, is non-empty.
    # This ensures that if `jq` returns just newlines or spaces, it's treated as empty.
    if [[ -n "${tw_output//[[:space:]]/}" ]]; then
        # Add a space for separation, then color and brackets for the tags.
        # You can adjust the color (e.g., fg[cyan], fg[yellow], etc.)
        # and the surrounding characters (e.g., (), <>, -).
        echo " %{$fg[white]%}[${tw_output}]%{$reset_color%}"
    fi
}

PROMPT='%(?, ,%{$fg[red]%}FAIL%{$reset_color%}$(echoti bel)
)
%{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%}: %{$fg_bold[blue]%}%~%{$reset_color%}$(display_tw_tags)$(git_prompt_info)
 $(prompt_char) '

RPROMPT='%{$fg[green]%}[%*]%{$reset_color%}'
