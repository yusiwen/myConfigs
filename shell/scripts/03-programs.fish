#!/usr/bin/env fish

# {{{ GoLang
if test -e /usr/local/go/bin/go || test -e /opt/go/bin/go || test -e "$HOME"/.local/go/bin/go
  set GOROOT /usr/local/go
  if not test -e "$GOROOT"
    if test -e "/opt/go/bin/go"
      set GOROOT /opt/go
    else if test -e "$HOME"/.local/go/bin/go
      set GOROOT "$HOME"/.local/go
    end 
  else
    set GOROOT ''
  end 
  export GOROOT
  export GOPATH=$HOME/.gopackages
  mkdir -p "$GOPATH"
  export GO111MODULE=on
  export GOPRIVATE=git.yusiwen.cn
  export GOPROXY=https://goproxy.cn,direct

  fish_add_path "$GOROOT/bin"
  fish_add_path "$GOPATH/bin"
end
#}}}

if ! check_command nvim
  fish_add_path "/opt/apps/nvim/bin"
end