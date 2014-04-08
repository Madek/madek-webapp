# {{ ansible_managed }} 
function rbenv-load(){
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
}
