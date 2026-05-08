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

```bash
# List all secret keys
gpg --list-secret-keys --keyid-format=long

# Export a public key
gpg --armor --export KEY_ID

# Restart GPG agent (if having issues)
gpg-connect-agent reloadagent /bye

# Edit a key (change expiration, add email, etc.)
gpg --edit-key KEY_ID
```

## Extending an Expired Key

If a key has expired (or is about to), the recommended path is to **extend its
expiration**, not generate a new one. Extending preserves the fingerprint, so
prior signed commits stay verified and you don't need to re-establish trust
with collaborators. Only rotate if the secret key may be compromised, you've
lost the secret material, or the algorithm is weak.

Symptom that prompts this: `gpg: skipped "<KEY_ID>": Unusable secret key` when
trying to commit, and `gpg --list-secret-keys` shows `[expired: <date>]`.

### Step 1: Open the key for editing

```bash
gpg --edit-key KEY_ID
```

You'll land at a `gpg>` prompt. The header will list the primary key and any
subkeys, each with `usage:` flags. `[SC]` = Sign + Certify (primary),
`[E]` = Encrypt (usually a subkey), `[S]` = a separate signing subkey.

### Step 2: Extend the primary key

At the `gpg>` prompt:

```
gpg> expire
```

Enter a new expiration when prompted. Recommended values:

- `1y` — one year (good default)
- `2y` — two years
- `0` — never expires (not recommended; the expiration date is what protects
  you if you lose access to the key)

You'll be prompted for your passphrase to confirm.

### Step 3: Extend each subkey (if any)

Subkeys have their own expiration dates and must be extended separately. If
`gpg --list-secret-keys` showed any `ssb` lines, repeat for each:

```
gpg> key 1
gpg> expire
```

`key 1` selects the first subkey (you'll see a `*` appear next to it). Run
`expire` again and pick the same expiration. To select another subkey,
deselect the current one first by running `key 1` again (the `*` toggles
off), then `key 2`, etc.

If `gpg --list-secret-keys` showed no `ssb` lines, skip this step — you only
have a primary key.

### Step 4: Save and exit

```
gpg> save
```

This writes the changes and exits. Verify with:

```bash
gpg --list-secret-keys --keyid-format=long
```

The `[expired: ...]` tag should now be `[expires: <new-date>]`.

### Step 5: Re-publish the public key

The updated expiration is part of the public key, so anywhere the old version
is published needs the new one.

```bash
gpg --armor --export KEY_ID
```

- **GitHub**: [Settings → SSH and GPG keys](https://github.com/settings/keys).
  GitHub accepts updates to existing keys — paste the new export to replace
  the old one (no need to delete first).
- **Keyservers**, if you publish there:
  ```bash
  gpg --send-keys KEY_ID
  ```

### Step 6: Verify signing works

```bash
git commit --allow-empty -m "Test signing after key extension"
git log --show-signature -1
```

You should see `Good signature` and the new expiration date.

## Troubleshooting

**GPG agent not starting:**
```bash
# Restart the GPG agent
gpg-connect-agent reloadagent /bye
```

**Passphrase prompts:**
- The configuration caches your passphrase for 12 hours
- You'll only need to enter it once per session

**Commits not showing as verified:**
- Ensure your email in Git config matches the email in your GPG key
- Check that your public key is added to GitHub
- Verify the key ID is correct in your configuration

**Key expired (`Unusable secret key` when signing):**
See [Extending an Expired Key](#extending-an-expired-key) above for the full
flow, including subkey handling and re-publishing to GitHub.

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
