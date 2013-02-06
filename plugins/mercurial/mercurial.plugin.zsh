
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

function hg_current_branch() {
  if [ -d .hg ]; then
    echo $(hg branch)
  fi
}

function hg_prompt_info() {
  ref=$(hg_current_branch)
  if [[ -n "$ref" ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref}$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}
