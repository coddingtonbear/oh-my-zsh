
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[white]%}⎇"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_CLEAN=""

function prompt_char {
	if [ $UID -eq 0 ]; then echo "%{$fg[red]%}ᐷ%{$reset_color%}"; else echo ᐷ; fi
}

function display_tw_tags() {
    local tw_active_status
    local json_output
    local tw_json_status
    local tags_output

    # Ensure `tw` and `jq` commands exist before attempting to run them.
    # This prevents errors if they are not installed.
    if ! command -v tw >/dev/null 2>&1; then
        return # tw command not found, so no output
    fi
    if ! command -v jq >/dev/null 2>&1; then
        return # jq command not found, so no output
    fi

    # Condition 1 (Highest Priority):
    # Check if `tw get dom.active` returns "0"
    # Use `command` to avoid issues with aliases/functions. Redirect stderr to /dev/null.
    tw_active_status=$(command tw get dom.active 2>/dev/null)
    if [[ "$tw_active_status" == "0" ]]; then
        echo " %{$fg[red]%}NO%{$reset_color%}"
        return
    fi

    # Try to get the JSON output from `tw get dom.active.json`
    # Capture its output and exit status.
    json_output=$(tw get dom.active.json 2>/dev/null)
    tw_json_status=$?

    # If `tw get dom.active.json` itself failed or returned empty/malformed output,
    # we can't proceed to check for tags or "NULL" reliably.
    # In this case, we simply return, displaying nothing for tags.
    if (( tw_json_status != 0 )) || [[ -z "$json_output" ]]; then
        echo " %{$fg[red]%}⬤%{$reset_color%}"
        return
    fi

    # Condition 2 (Medium Priority):
    # Check if there is NO "tags" field or if "tags" is not an array.
    # We use `jq -e '.tags | type == "array"'`
    # `-e` makes `jq` exit with a non-zero status if the expression evaluates to false or null.
    # `type == "array"` ensures it's specifically an array, not just null or a string.
    echo "$json_output" | jq -e '.tags | type == "array"' >/dev/null 2>&1
    local tags_field_is_array=$? # 0 if true, non-zero if false or missing/wrong type

    if (( tags_field_is_array != 0 )); then
        echo " %{$fg[yellow]%}⬤%{$reset_color%}"
        return
    fi

    # Condition 3 (Lowest Priority / Default):
    # 'tags' field exists and is an array. Extract and display.
    # `jq -r '.tags | join("|")'` will produce an empty string if the array is empty.
    tags_output=$(echo "$json_output" | jq -r '.tags | join("|")' 2>/dev/null)

    echo " %{$fg[green]%}⬤${(S)tags_output}%{$reset_color%}"
}

PROMPT='%(?, ,%{$fg[red]%}FAIL%{$reset_color%}$(echoti bel)
)
%{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%}: %{$fg_bold[blue]%}%~%{$reset_color%}$(display_tw_tags)$(git_prompt_info)
$(prompt_char) '

RPROMPT='%{$fg[green]%}[%*]%{$reset_color%}'
