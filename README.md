Here’s a polished `README.md` for the standalone repo. On GitHub, create or edit `README.md`, then paste everything below:

```markdown
# XGS Login Banner

A lightweight, standalone Bash installer that displays an XGS system-information banner when you start an interactive login session.

The banner shows your host, operating system, kernel, uptime, load, CPU count, memory, root-disk usage, and IP addresses.

## Install

Review the installer before running it, then install with:

```bash
git clone --depth 1 https://github.com/xgshost/xgs-login-banner.git
cd xgs-login-banner
sudo bash install-xgs.sh
```

Already cloned the repository? Update it and run the installer:

```bash
cd ~/xgs-login-banner && git pull --ff-only origin main && sudo bash install-xgs.sh
```

## What the installer changes

- Installs the banner at `/usr/local/bin/xgs-banner`.
- Adds `/etc/profile.d/xgs-banner.sh` to display it in interactive login sessions.
- Comments out active `pam_motd.so` lines in `/etc/pam.d/sshd` and `/etc/pam.d/login`.
- Saves a `.xgs-backup` copy of each PAM file before changing it.

> **Note:** Disabling PAM MOTD lines can prevent your system’s usual login message from appearing. The installer modifies system files and must be run as root. Review the script before installing.

## Requirements

- Linux with Bash
- Root privileges (`sudo`)
- Standard system utilities such as `free`, `df`, `awk`, and `hostname`

## Uninstall

Remove the installed banner and profile script:

```bash
sudo rm -f /usr/local/bin/xgs-banner /etc/profile.d/xgs-banner.sh
```

To restore the PAM files from the backups made by the installer, first check that the backups exist:

```bash
sudo ls -l /etc/pam.d/sshd.xgs-backup /etc/pam.d/login.xgs-backup
```

Restore only the files you want to revert. Restoring a backup replaces the current PAM file, so preserve any changes made since installation:

```bash
sudo cp -a /etc/pam.d/sshd.xgs-backup /etc/pam.d/sshd
sudo cp -a /etc/pam.d/login.xgs-backup /etc/pam.d/login
```

