trap 'echo "git sign setup has been interrupted"; exit 1' 2

git config --global gpg.format ssh

email=$(git config --get user.email || "")
if [ -z "$email" ]; then
    echo "Seems like you haven't set up your git yet."
    read -p "Enter your email address: " email < /dev/tty
    git config --global user.email "$email"
    name=$(git config --get user.name || "")
    if [ -z "$name" ]; then
        read -p "Enter your name: " name < /dev/tty
        git config --global user.name "$name"
    fi
fi

dir="$HOME/.ssh"
mkdir -p "$dir"

file="$dir/gitsign"
path="$file.pub"

ssh-keygen -t ed25519 -C "$(echo $email | xargs)" -N "" -f "$file" < /dev/tty

git config --global commit.gpgsign true
git config --global user.signingkey "$path"

if ! pgrep -x ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi

ssh-add "$file"

if ! gh auth status; then
    echo "Seems like you haven't set up your gh yet."
    gh auth login -w -h github.com -s admin:ssh_signing_key,repo,gist,workflow,read:org < /dev/tty
fi

read -p "Enter your SSH key display name for GitHub (leave empty to skip signing key creation): " keyname < /dev/tty
if [ -n "$keyname" ]; then
    gh ssh-key add "$path" --type signing --title "$keyname"
    echo "SSH signing key added to GitHub."
else
    echo "Skipping SSH signing key upload to GitHub."
fi

echo "git sign setup has been completed"
