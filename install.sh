#!/bin/bash

# Define the filenames
DOTFILES=(.vimrc .bashrc .gitconfig)

# Backup Directory
BACKUP_DIR="$HOME/dotfiles_backup"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Creating backup of dotfiles..."

# Iterate through each dotfile
for file in "${DOTFILES[@]}"; do
  if [ -f "$HOME/$file" ]; then
    # Check if the file exists and is a regular file
    echo "Backing up $file..."
    cp "$HOME/$file" "$BACKUP_DIR/$file"
  else
    echo "$file not found, skipping..."
  fi
done

echo "Backup complete."

# Ask if the user wants to install new dotfiles
echo "Do you want to install new dotfiles (Y/N)?"
read -r install_choice

if [[ "$install_choice" =~ ^[Yy]$ ]]; then
  echo "Installing dotfiles..."

  # Iterate through each dotfile and copy from the current directory (dotfiles directory)
  for file in "${DOTFILES[@]}"; do
    if [ -f "$file" ]; then
      echo "Copying $file to home directory..."
      cp "$file" "$HOME/$file"
    else
      echo "$file not found in the current directory, skipping..."
    fi
  done

  echo "Dotfiles installation complete."
else
  echo "Skipping installation of new dotfiles."
fi
