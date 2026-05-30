typeset -U path
path=($HOME/.config/emacs/bin)

for dir in \
  $HOME/.cargo/bin \
  /opt/homebrew/opt/openjdk/bin \
  $HOME/go/bin \
  /opt/homebrew/opt/node@20/bin \
  /opt/homebrew/opt/libtool/libexec/gnubin \
  /opt/homebrew/bin \
  /opt/homebrew/sbin \
  $HOME/.local/bin \
  $HOME/.orbstack/bin \
  "$BUN_INSTALL/bin" \
  $HOME/Library/Android/sdk/platform-tools
do
  [ -d "$dir" ] && path=("$dir" $path)
done

path+=(/usr/local/bin /usr/bin /bin /usr/sbin /sbin)

export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include -I/opt/homebrew/opt/node@20/include"
export LDFLAGS="-L/opt/homebrew/opt/node@20/lib"
export EDITOR="zed"
export VISUAL="zed"

. "$HOME/.cargo/env"
