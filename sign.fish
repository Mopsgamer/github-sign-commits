set required_cmds git ssh-keygen pgrep ssh-agent ssh-add gh read awk grep xargs mkdir

for cmd in $required_cmds
    if not type -q $cmd
        echo "Error: Required command '$cmd' not found. Please install it before running this script."
        exit 1
    end
end

function on_interrupt --on-signal SIGINT
    echo "git sign setup has been interrupted"
    exit 1
end

git config --global gpg.format ssh

set email (git config --get user.email)
if test -z "$email"
    echo "Seems like you haven't set up your git yet."
    read -l -p "Enter your git email address: " email
    git config --global user.email "$email"
end

set name (git config --get user.name)
if test -z "$name"
    echo "Seems like you haven't set up your git yet."
    read -l -p "Enter your git name: " name
    git config --global user.name "$name"
end

set dir "$HOME/.ssh"
mkdir -p $dir

set file "$dir/gitsign"
set path "$file.pub"

ssh-keygen -t ed25519 -C (echo $email | xargs) -N "" -f $file < /dev/tty

git config --global commit.gpgsign true
git config --global user.signingkey "$path"

if not pgrep -x ssh-agent > /dev/null
    eval (ssh-agent -c)
end

set key_fingerprint (ssh-keygen -lf $file | awk '{print $2}')
if not ssh-add -l | grep -q $key_fingerprint
    ssh-add $file > /dev/null
end

if not gh auth status > /dev/null
    echo "Seems like you haven't set up your gh yet."
    gh auth login -w -h github.com -s admin:ssh_signing_key,repo,gist,workflow,read:org < /dev/tty
end

read -l -p "Enter your SSH key display name for GitHub (leave empty to skip signing key creation): " keyname
if test -n "$keyname"
    gh ssh-key add "$path" --type signing --title "$keyname" > /dev/null
    echo "SSH signing key added to GitHub."
else
    echo "Skipping SSH signing key upload to GitHub."
end

echo "git sign setup has been completed"
