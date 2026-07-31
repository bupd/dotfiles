IDENTITY BACKUP
===============

This tool backs up GPG signing keys, SSH keys, and the other locations listed in
paths.txt. The result is an ordinary, UNENCRYPTED ZIP file.

CREATE THE BACKUP IN ~/identity-backup

  ~/identity-backup/backup.sh ~/identity-backup

The resulting file will look like:

  ~/identity-backup/identity-backup-YYYY-MM-DD_HH-MM-SS.zip

Copy that ZIP to the new device before restoring.

RESTORE SAFELY FOR INSPECTION

This extracts into a new directory without changing files in your home directory:

  ~/identity-backup/restore.sh ~/identity-backup/identity-backup-DATE.zip

RESTORE DIRECTLY ON A NEW DEVICE

  ~/identity-backup/restore.sh --home ~/identity-backup/identity-backup-DATE.zip

Direct restoration can overwrite existing files. The script asks you to type
RESTORE before proceeding. Direct home restores intentionally skip
~/.local/share/keyrings so an old login keyring does not break the new system
password.

GPG SIGNING KEYS

The backup includes ~/.gnupg, containing public keys, private keys, trust data,
configuration, and revocation certificates.

After restoring, check that the private signing key is available:

  gpg --list-secret-keys --keyid-format long

If Git is not already configured to use it:

  git config --global user.signingkey YOUR_KEY_ID
  git config --global commit.gpgsign true

Replace YOUR_KEY_ID with the key ID shown by the GPG command.

If a key is stored on a YubiKey or smartcard, the private key remains on that
hardware. The backup contains only GPG's local reference to it.

SSH KEYS

The backup includes all of ~/.ssh: private keys, public keys, config, known_hosts,
and authorized_keys.

After restoring, set permissions SSH will accept:

  find ~/.ssh -type d -exec chmod 700 {} +
  find ~/.ssh -type f -exec chmod 600 {} +
  find ~/.ssh -type f -name '*.pub' -exec chmod 644 {} +

Load a key, replacing its filename if necessary:

  ssh-add ~/.ssh/id_ed25519

For a GitHub key, test it with:

  ssh -T git@github.com

DOCKER AND KUBERNETES

The backup includes ~/.docker, including Docker login configuration, and all of
~/.kube, including files named *.kubeconfig.yaml.

Docker credential helpers may store credentials in an OS keyring rather than in
~/.docker/config.json. Do not restore ~/.local/share/keyrings directly onto a
new Linux desktop. The GNOME login keyring is encrypted with the old login
password, so restoring it can cause repeated "login keyring" unlock prompts after
moving to a new system or changing the account password.

If you need old desktop secrets, restore the archive into a staging directory and
copy/export individual credentials intentionally. Let the new system create its
own fresh login keyring.

Kubeconfig files can refer to certificates or keys outside ~/.kube. Add those
external paths to paths.txt if you use them.

CHANGING WHAT IS BACKED UP

Edit ~/identity-backup/paths.txt. Paths are relative to your home directory.
Missing paths are skipped automatically.

IMPORTANT SECURITY WARNING

The ZIP is not encrypted. Anyone who can read or copy it can use the private keys
and credentials inside it. Store it only on trusted storage with restricted
permissions, and delete unwanted copies securely.
