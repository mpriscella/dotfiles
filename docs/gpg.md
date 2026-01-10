# GPG Setup for Git Signing

This repository includes GPG commit signing configuration. Follow these steps to
set up GPG keys for signing your Git commits.

## 1. Generate a New GPG Key

```bash
# Start the key generation process
gpg --full-generate-key
```

Follow the prompts:

1. **Key type**: Select `RSA and RSA` (option 1)
2. **Key size**: Enter `4096` for maximum security
3. **Expiration**: Choose based on your security policy:
   - `0` = key does not expire (not recommended)
   - `2y` = expires in 2 years (recommended)
   - `1y` = expires in 1 year
4. **Real name**: Enter your full name (e.g., "Mike Priscella")
5. **Email**: Enter the email associated with your Git commits
6. **Comment**: Optional, can leave blank
7. **Passphrase**: Choose a strong passphrase (you'll need this for signing)

## 2. List Your GPG Keys

```bash
# List all secret keys with long format key IDs
gpg --list-secret-keys --keyid-format=long

# Or use the provided alias
gpg-list
```

Output will look like:
```
sec   rsa4096/ABC123DEF456 2025-06-18 [SC] [expires: 2027-06-18]
      1234567890ABCDEF1234567890ABCDEF12345678
uid                 [ultimate] Mike Priscella <mpriscella@gmail.com>
ssb   rsa4096/XYZ789UVW012 2025-06-18 [E] [expires: 2027-06-18]
```

Your **GPG Key ID** is `ABC123DEF456` (the part after `rsa4096/`).

## 3. Export Your Public Key

```bash
# Export your public key (replace with your actual key ID)
gpg --armor --export ABC123DEF456

# Or use the provided alias
gpg-export ABC123DEF456
```

Copy the entire output (including `-----BEGIN PGP PUBLIC KEY BLOCK-----` and `-----END PGP PUBLIC KEY BLOCK-----`).

## 4. Add Public Key to GitHub

1. Go to [GitHub Settings → SSH and GPG keys](https://github.com/settings/keys)
2. Click **"New GPG key"**
3. Paste your public key
4. Click **"Add GPG key"**

## 5. Configure Your Dotfiles

Add your GPG key ID to your machine's configuration in `flake.nix`:

```nix
darwinConfigurations = {
  "your-machine-name" = mkDarwinConfiguration {
    username = "yourusername";
    gpgSigningKey = "ABC123DEF456"; # Replace with your key ID
  };
};
```

For standalone Home Manager configurations (Linux), add the key to `homeConfigurations`:

```nix
homeConfigurations = {
  "linux-arm" = mkHomeConfiguration {
    system = "aarch64-linux";
    username = "yourusername";
    gpgSigningKey = "ABC123DEF456"; # Replace with your key ID
  };
};
```

## 6. Apply Configuration

```bash
# For macOS (nix-darwin)
sudo darwin-rebuild switch --flake .#your-machine-name

# For Linux (standalone Home Manager)
home-manager switch --flake .#linux
```

## 7. Test GPG Signing

```bash
# Test GPG functionality
echo "test" | gpg --clearsign

# Make a test commit
git commit --allow-empty -m "Test GPG signing"

# Verify the commit is signed
git log --show-signature -1
```

You should see output like:
```
gpg: Signature made Wed Jun 18 10:30:00 2025 PDT
gpg:                using RSA key ABC123DEF456
gpg: Good signature from "Mike Priscella <mpriscella@gmail.com>"
```

## Multiple Keys for Different Contexts

This dotfiles setup supports different GPG keys for different machines:

- **Work Machine**: Use your work email and work GPG key
- **Personal Machine**: Use your personal email and personal GPG key
- **Default/Testing**: Can be set to `null` to disable signing

## GPG Key Management Commands

The dotfiles include helpful aliases:

```bash
# List all secret keys
gpg-list

# Export a public key
gpg-export KEY_ID

# Restart GPG agent (if having issues)
gpg-restart

# Edit a key (change expiration, add email, etc.)
gpg --edit-key KEY_ID
```

## Troubleshooting

**GPG agent not starting:**
```bash
# Restart the GPG agent
gpg-restart

# Or manually
gpg-connect-agent reloadagent /bye
```

**Passphrase prompts:**
- The configuration caches your passphrase for 12 hours
- You'll only need to enter it once per session

**Commits not showing as verified:**
- Ensure your email in Git config matches the email in your GPG key
- Check that your public key is added to GitHub
- Verify the key ID is correct in your configuration

**Key expiration:**
```bash
# Extend key expiration
gpg --edit-key KEY_ID
gpg> expire
gpg> save

# Re-export and update on GitHub
gpg-export KEY_ID
```

## Security Best Practices

1. **Use a strong passphrase** for your GPG key
2. **Set key expiration** (1-2 years recommended)
3. **Backup your keys securely**:
   ```bash
   # Export private key for backup (store securely!)
   gpg --export-secret-keys --armor KEY_ID > private-key-backup.asc
   ```
4. **Use different keys** for work and personal contexts
5. **Revoke compromised keys** immediately:
   ```bash
   gpg --gen-revoke KEY_ID > revocation-cert.asc
   ```

## References

- [GitHub GPG Documentation](https://docs.github.com/en/authentication/managing-commit-signature-verification)
- [GnuPG Documentation](https://gnupg.org/documentation/)
- [Git Signing Documentation](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
