# github-sign-commits
Scripts for automatic git signing setup.

AKA Verified commits.

## ![Static Badge](https://img.shields.io/badge/SSH-ed25519-green?labelColor=gray)

### PowerShell
```bash
irm https://raw.githubusercontent.com/Mopsgamer/github-sign-commits/refs/heads/main/sign.ps1 | iex
```

### Bash
```bash
curl -fsSL https://raw.githubusercontent.com/Mopsgamer/github-sign-commits/refs/heads/main/sign.sh | bash
```

### Check

```bash
ssh-keygen -l -f ~/.ssh/gitsign.pub | sed 's/\(SHA256:\)[^[:space:]]*/\1**/g'
git config user.signingkey
git config gpg.format
```
