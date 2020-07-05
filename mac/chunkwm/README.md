# ChunkWM on Mac OS

## Prerequisite

xcode command-line tools

## Installation

```sh
# skhd
brew install koekeishiya/formulae/skhd
cp /usr/local/opt/skhd/share/skhd/examples/skhdrc ~/.skhdrc
brew services start skhd

# clone tap
brew tap crisidev/homebrew-chunkwm

# install latest stable version
brew install chunkwm

cp /usr/local/opt/chunkwm/share/chunkwm/examples/chunkwmrc ~/.chunkwmrc

brew services start chunkwm
```
