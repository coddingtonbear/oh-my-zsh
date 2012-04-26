
# Mercurial
alias hgc='hg commit'
alias hgb='hg branch'
alias hgba='hg branches'
alias hgco='hg checkout'
alias hgd='hg diff'
alias hged='hg diffmerge'
# pull and update
alias hgl='hg pull -u'
alias hgp='hg push'
alias hgs='hg status'
# this is the 'git commit --amend' equivalent
alias hgca='hg qimport -r tip ; hg qrefresh -e ; hg qfinish tip'

function set_hg_branch_info() {
    HG_BRANCH=""
    # Tries to use FastRoot first -- https://bitbucket.org/yaniv_aknin/fast_hg_root
    root=$(fast_hg_root 2> /dev/null)
    retcode="${?}"
    if [ "${retcode}" -eq "0" ] ; then
        HG_BRANCH=$(cat ${root}/.hg/branch 2> /dev/null) || return
        return true
    elif [ "${retcode}" -eq "127" ]; then
        HG_BRANCH=$(hg branch 2> /dev/null) || return
        return true
    fi
    return false
}

function hg_prompt_info() {
    if [ -n "$HG_BRANCH" ]; then
        echo "$ZSH_THEME_GIT_PROMPT_PREFIX%{$HG_BRANCH%}$ZSH_THEME_GIT_PROMPT_SUFFIX"
    else
        echo ""
    fi
}

PERIOD=60
add-zsh-hook chpwd set_hg_branch_info
add-zsh-hook periodic set_hg_branch_info
