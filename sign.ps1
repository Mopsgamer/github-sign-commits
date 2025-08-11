$required_cmds = @('git', 'ssh-keygen', 'ssh-agent', 'ssh-add', 'gh')
foreach ($cmd in $required_cmds) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "Error: Required command '$cmd' not found. Please install it before running this script."
        exit 1
    }
}

trap {
    Write-Host "git sign setup has been interrupted"
    exit 1
}

git config --global gpg.format ssh

$email = git config --get user.email
if ([string]::IsNullOrEmpty($email)) {
    Write-Host "Seems like you haven't set up your git yet."
    $email = Read-Host "Enter your git email address"
    git config --global user.email $email
}

$name = git config --get user.name
if ([string]::IsNullOrEmpty($name)) {
    Write-Host "Seems like you haven't set up your git yet."
    $name = Read-Host "Enter your git name"
    git config --global user.name $name
}

$dir = "C:/Users/$Env:UserName/.ssh"
if (!(Test-Path -Path $dir)) {
    New-Item -ItemType Directory -Path $dir
}

$file = "$dir/gitsign"
$path = "$file.pub"
ssh-keygen -t ed25519 -C $email.Trim() -N "" -f $file

git config --global commit.gpgsign true
git config --global user.signingkey $path
if(!(Get-Service -Name ssh-agent | Set-Service -StartupType Manual)) {
    exit 1
}
Start-Service ssh-agent
ssh-add $file


if (!(gh auth status)) {
    Write-Host "Seems like you haven't set up your gh yet."
    if (!(gh auth login -w -h github.com -s admin:ssh_signing_key,repo,gist,workflow,read:org) {
		exit 1
    }
}
$keyname = Read-Host "Enter your SSH key display name for GitHub (leave empty to skip signing key creation)"
if (-not [string]::IsNullOrWhiteSpace($keyname)) {
    if (!(gh ssh-key add $path --type signing --title $keyname) {
		if (!(gh auth refresh -h github.com -s admin:ssh_signing_key,repo,gist,workflow,read:org)) {
			exit 1
		}
		if (!(gh ssh-key add $path --type signing --title $keyname)) {
			exit 1
		}
	}
    Write-Host "SSH signing key added to GitHub."
} else {
    Write-Host "Skipping SSH signing key upload to GitHub."
}
Write-Host "git sign setup has been completed"
