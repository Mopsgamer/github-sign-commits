# github-sign-commits
Scripts for automatic git signing setup.

AKA Verified commits.

## ![Static Badge](https://img.shields.io/badge/SSH-ed25519-green?labelColor=gray)

### PowerShell
```bash
irm https://raw.githubusercontent.com/Mopsgamer/github-sign-commits/refs/heads/main/sign.ps1 | iex
```
```bash
# $PROFILE
# Ensure the ssh-agent service is running
$agentService = Get-Service ssh-agent -ErrorAction SilentlyContinue
if ($agentService.Status -ne 'Running') {
    Start-Service ssh-agent
}

ssh-add "$HOME\.ssh\gitsign" 2>$null
```

### Bash
```bash
curl -fsSL https://raw.githubusercontent.com/Mopsgamer/github-sign-commits/refs/heads/main/sign.sh | bash
```
```bash
# ~/.bashrc
# Ensure the ssh-agent service is running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
fi
ssh-add "$HOME/.ssh/gitsign" 2>/dev/null
```
```fish
# ~/.config/fish/config.fish
# Ensure the ssh-agent service is running
if not pgrep -u $USER ssh-agent > /dev/null
    eval (ssh-agent -c) > /dev/null
end
ssh-add $HOME/.ssh/gitsign 2>/dev/null
```

### Check

```bash
# WARNING: Sensitive data output
ssh-keygen -l -f ~/.ssh/gitsign.pub | sed 's/\(SHA256:\)[^[:space:]]*/\1**/g'
git config user.signingkey
git config gpg.format
```
