#!/bin/bash 
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
