#!/bin/bash 

# install homebrew
if [ ! command -v brew &> /dev/null ]
then
  echo "Installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed"
fi


# Install from Brewfile
brew bundle --file=$HOME/dotfiles/Brewfile

# symlink tmux config
if [ ! -e "$HOME/.tmux.conf" ]; then
  echo "Symlinking tmux config...." 
  ln -s "$HOME/dotfiles/.tmux.conf" "$HOME/.tmux.conf"
  echo "tmux symlinked"
else
  echo "tmux config already exists"
fi

# symlink nvim 
if [ ! -d "$HOME/.config/nvim" ]; then
  echo "symlinking nvim config"
  ln -s "$HOME/dotfiles/nvim" "$HOME/.config/nvim"
  echo "nvim config symlinked"
else
  echo "nvim config already exists"
fi


# symlink zsh

if [ ! -e "$HOME/.zshrc" ]; then
  echo "symlinking .zshrc"
  ln -s "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
  source "$HOME/.zshrc"
  echo ".zshrc symlinked"
else
  echo ".zshrc already exists"
fi

# symlink bin folder scripts
 echo "symlinking scripts in /bin"
 for file in "$HOME/dotfiles/bin"/*; do
   # Only procede if the file is a script
   if [[ -x "$file" && -f "$file" ]]; then 
     #extract file name 
     file_name="$(basename "$file")"

     echo "symlinking ${file_name}" 

     #create symlink
     ln -sfn "$file" "$HOME/.local/bin/$file_name"
   fi
 done
 unset file
