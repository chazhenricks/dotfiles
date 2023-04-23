#!/bin/bash 

# install homebrew
if  ! command -v brew &> /dev/null 
then
  echo "Installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed"
fi


#install oh my zsh
echo "checking oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "oh-my-zsh not installed, installing now"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "oh-my-zsh installed"
else
  echo "oh-my-zsh already installed"
fi

# Ask if Install from Brewfile
read -p "Install dependencied from Brewfile? (Y/N)" choice
case "$choice" in 
  y|Y )
    echo "installing from Brewfile"
    brew bundle --file=$HOME/dotfiles/Brewfile
    ;;
  n|N ) 
    echo "skipping Brewfile install"
    ;;
  * )
    echo "dont be a dingus"
    ;;
esac
    
    

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

if [ ! -e "$HOME/.zshrc" ] && [ ! -h "$HOME/.zshrc"]; then
  echo "symlinking .zshrc"
  ln -s "$HOME/dotfiles/zsh/.zshrc" "$HOME/.zshrc"
  source "$HOME/.zshrc"
  echo ".zshrc symlinked"
else
  read -p ".zshrc file aready exists. Do you want to yeet it and symlink new? (Y|N)? " choice
  case "$choice" in 
    y|Y ) 
      echo "yeeting .zshrc..."
      rm "$HOME/.zshrc"
      echo "symlinking new .zshrc"
      ln -s "$HOME/dotfiles/zsh/.zshrc" "$HOME/.zshrc"
      source "$HOME/.zshrc"
      echo ".zshrc symlinked"
      ;;
    n|N ) 
      echo "keeping current .zshrc"
      ;;
    * )
      echo "god, youre the worst"
      ;;
  esac 
fi

# symlink bin folder scripts
 echo "symlinking scripts in /bin"
 for file in "$HOME/dotfiles/bin"/*; do
   # Only procede if the file is a script
   if [[ -x "$file" && -f "$file" ]]; then 
     #extract file name 
     file_name="$(basename "$file")"

     echo "symlinking ${file_name}" 
    #create $HOME/.local/bin directory if it doesnt exist 
    if [ ! -d "$HOME/.local/bin" ]; then 
      mkdir -p "$HOME/.local/bin"
    fi
     #create symlink
     ln -sfn "$file" "$HOME/.local/bin/$file_name"
   fi
 done
 unset file
