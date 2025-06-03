git config --global gpg.format ssh
$email = git config --get user.email
if ([string]::IsNullOrEmpty($email)) {
    Write-Host "Seems like you haven't set up your git yet."
    $email = Read-Host "Enter your email address"
    git config --global user.email $email
    $name = git config --get user.name
    if ([string]::IsNullOrEmpty($name)) {
        $name = Read-Host "Enter your name"
        git config --global user.name $name
    }
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
Get-Service -Name ssh-agent | Set-Service -StartupType Manual
Start-Service ssh-agent
ssh-add $file


if (!(gh auth status)) {
    Write-Host "Seems like you haven't set up your gh yet."
    gh auth login -h github.com -s admin:ssh_signing_key repo gist workflow read:org
}
$keyname = Read-Host "Enter your ssh key display name for GitHub"
gh ssh-key add $path --type signing --title $keyname
Write-Host "git sign setup has been completed"
pause
