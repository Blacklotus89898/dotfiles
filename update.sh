#!/bin/bash

# Define the filenames
DOTFILES=(.vimrc .bashrc .gitconfig)

# Dotfiles Repository Directory
DOTFILES_REPO_DIR="$(pwd)"  # Change this to the path of your dotfiles repo

# Check if the dotfiles repository directory exists
if [ ! -d "$DOTFILES_REPO_DIR" ]; then
  echo "Dotfiles repository not found at $DOTFILES_REPO_DIR. Exiting..."
  exit 1
fi

echo "Copying current dotfiles to the dotfiles repository..."

# Iterate through each dotfile and copy it to the repository
for file in "${DOTFILES[@]}"; do
  if [ -f "$HOME/$file" ]; then
    echo "Copying $file to the dotfiles repository..."
    cp "$HOME/$file" "$DOTFILES_REPO_DIR/$file"
  else
    echo "$file not found in the home directory, skipping..."
  fi
done

echo "Dotfiles have been updated in the repository."

# Optionally, you could also automate git commit and push after copying the files.

echo "Do you want to commit and push the changes to your dotfiles repo (Y/N)?"
read -r commit_choice

if [[ "$commit_choice" =~ ^[Yy]$ ]]; then
  echo "Committing and pushing changes..."

  # Change directory to the dotfiles repository
  cd "$DOTFILES_REPO_DIR" || exit

  # Stage the changes
  git add .

  # Commit the changes
  git commit -m "Updated dotfiles from home directory"

  # Push the changes to the remote repository
  git push origin main  # Make sure your default branch is `main`, or change it accordingly

  echo "Changes committed and pushed to the repository."
else
  echo "Skipping commit and push."
fi

