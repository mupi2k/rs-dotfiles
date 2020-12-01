#==============
# Install all the packages
#==============
sudo chown -R $(whoami):admin /usr/local
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew doctor
brew update

# So we use all of the packages we are about to install
echo "export PATH='/usr/local/bin:$PATH'\n" >> ~/.bashrc
source ~/.bashrc

info () {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

link_files () {
  if [ -n "$(find ~/dotfiles/custom-configs -name $1)" ]; then
    ln -s ~/dotfiles/custom-configs/**/$1 $2
    success "linked $HOME/dotfiles/custom-configs/$1 to $2"
  else
    case "$1" in
      zshrc )
        ln -s $HOME/dotfiles/zsh/$1 $2;;
      zsh_prompt )
        ln -s $HOME/dotfiles/zsh/$1 $2;;
      * )
        ln -s ~/dotfiles/$1 $2;;
    esac

    success "linked $HOME/dotfiles/$1 to $2"
  fi
}

#==============
# Remove old dot flies
#==============
overwrite_all=false
backup_all=false
skip_all=false

for name in vim vimrc bashrc tmux tmux.conf zsh_prompt zshrc gitconfig psqlrc tigrc config Brewfile  
do 
    if [ $name = "Brewfile" ]
    then 
      dest="$HOME/$name"
    else
      dest="$HOME/.$name"
    fi
    source=$name
    echo " Processing $name..."
    if [ -e $dest ] || [ -d $dest ] 
    then
      overwite=false
      backup=false
      skip=false
      if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
      then
        user "File already exists: `basename $dest`, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac
      fi

      if [ "$overwrite" == "true" ] || [ "$overwrite_all" == "true" ]
      then
        echo "removing $dest"
        rm -rf $dest
        success "removed $dest"
      fi

      if [ "$backup" == "true" ] || [ "$backup_all" == "true" ]
      then
        mv $dest $dest\.backup
        success "moved $dest to $dest.backup"
      fi

      if [ "$skip" == "false" ] && [ "$skip_all" == "false" ]
      then
        link_files $source $dest
      else
        success "skipped $source"
      fi
    else
      link_files $source $dest
    fi
done
   

cd ~
brew bundle
cd -

#==============
# Set zsh as the default shell
#==============
chsh -s /bin/zsh

#==============
# And we are done
#==============
echo -e "\n====== All Done!! ======\n"
echo
echo "Enjoy -Mike"
