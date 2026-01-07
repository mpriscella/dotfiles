# Secrets Management with sops-nix

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) for managing
secrets. Secrets are encrypted with [age](https://github.com/FiloSottile/age)
and stored in the repository, then decrypted at runtime by Home Manager.

## How It Works

1. Secrets are encrypted and stored in `secrets/secrets.yaml`
2. Each host has its own age key pair
3. During `home-manager switch`, sops-nix decrypts secrets to secure locations
4. Shell initialization exports secrets as environment variables

## Initial Setup (New Host)

### 1. Generate an Age Key

```bash
# macOS
mkdir -p ~/Library/Application\ Support/sops/age
age-keygen -o ~/Library/Application\ Support/sops/age/keys.txt
chmod 600 ~/Library/Application\ Support/sops/age/keys.txt

# Linux
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

### 2. Get Your Public Key

```bash
# macOS
age-keygen -y ~/Library/Application\ Support/sops/age/keys.txt

# Linux
age-keygen -y ~/.config/sops/age/keys.txt
```

### 3. Add Your Key to `.sops.yaml`

Edit `.sops.yaml` and add your public key:

```yaml
keys:
  - &macbook_pro_m5 age1abc...  # existing key
  - &your_new_host age1xyz...   # your new key

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *macbook_pro_m5
          - *your_new_host
```

### 4. Re-encrypt Secrets for New Key

```bash
sops updatekeys secrets/secrets.yaml
```

## Adding or Editing Secrets

```bash
# Edit secrets (opens in $EDITOR, auto-encrypts on save)
sops secrets/secrets.yaml
```

The file will be decrypted for editing and re-encrypted when you save.

## Using Secrets in Nix Configuration

Secrets are defined in `home-manager/programs/sops.nix`:

```nix
sops.secrets = {
  github_mcp_token = {};
  # Add more secrets here
};
```

Secrets are decrypted to `$XDG_RUNTIME_DIR/secrets/<name>` (Linux) or a secure
temp location (macOS).

Access in other modules via `config.sops.secrets.<name>.path`:

```nix
# Example: Export as environment variable in fish
interactiveShellInit = ''
  if test -r ${config.sops.secrets.github_mcp_token.path}
    set -gx GITHUB_MCP_TOKEN (cat ${config.sops.secrets.github_mcp_token.path})
  end
'';
```

## Key File Locations

| Platform | Location                                          |
| -------- | ------------------------------------------------- |
| macOS    | `~/Library/Application Support/sops/age/keys.txt` |
| Linux    | `~/.config/sops/age/keys.txt`                     |

## Troubleshooting

**"Failed to get the data key" / "Recovery failed"**
- Ensure your age key file exists in the correct location for your platform
- Verify your public key is listed in `.sops.yaml`
- Run `sops updatekeys secrets/secrets.yaml` after adding new keys

**"No matching creation rules found"**
- The file path must match the regex in `.sops.yaml` (e.g., `secrets/*.yaml`)
- Encrypt files in-place: `sops -e -i secrets/secrets.yaml`

**Secrets not available after switch**
- Start a new shell session
- Check that `sops.secrets.<name>` is defined in `sops.nix`
- Verify the secret file exists: `ls -la /run/user/$(id -u)/secrets/` (Linux)

## Rotating the GitHub MCP Token

When your GitHub PAT expires or needs rotation:

### 1. Generate a New Token

1. Go to [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
2. Generate a new token with required scopes
3. Copy the new token

### 2. Update the Secret

```bash
# Edit the secrets file (decrypts automatically)
sops secrets/secrets.yaml
```

Update the `github_mcp_token` value with your new token:

```yaml
github_mcp_token: ghp_your_new_token_here
```

Save and exit. The file is automatically re-encrypted.

### 3. Apply Changes

```bash
# Rebuild to decrypt the new secret
darwin-rebuild switch --flake .#<hostname>
# or
home-manager switch --flake .#<hostname>
```

### 4. Restart Claude Code

The new token will be available after starting a new shell session or restarting Claude Code.

### 5. Revoke the Old Token

Go to [GitHub Settings → Personal access tokens](https://github.com/settings/tokens) and delete the old token.

## Security Best Practices

1. **Never commit unencrypted secrets** - Always use `sops -e` or edit via `sops <file>`
2. **Backup your age private key** securely (password manager, encrypted backup)
3. **Use separate keys per host** - Limits exposure if one machine is compromised
4. **Rotate secrets** if a key is compromised, then remove the old key and run `updatekeys`

## References

- [age](https://github.com/FiloSottile/age)
- [sops-nix](https://github.com/Mic92/sops-nix)
- [SOPS Documentation](https://getsops.io/docs/)
