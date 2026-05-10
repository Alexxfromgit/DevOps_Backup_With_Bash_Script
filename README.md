# Task 4.3 — Simple Backup

## Overview

A bash script that creates timestamped, compressed backups of a given directory and automatically rotates old archives to stay within a configurable limit.

---

## Scripts

### `task4_3.sh`

- Accepts two arguments: an absolute path to the source directory and the maximum number of backups to retain
- Creates the backup destination `/tmp/backups/` if it does not exist
- Archives and compresses the source directory with `tar` + `gzip`
- Names the archive `<dir>-<timestamp>.tar.gz`, where `/` in the path is replaced with `-` and the leading separator is dropped (e.g. `/etc/default` → `etc-default-2026-05-10-120000.tar.gz`)
- After creating a new backup, deletes the oldest archives for that directory so that no more than *n* copies remain
- Validates both arguments and prints a descriptive message to **stderr** with a non-zero exit code on any error

---

## Additional Requirements

1. Each run must either create a backup or display an error message — silent failure is not acceptable.
2. The script must validate the argument count and the existence of the source directory. On failure it must write to **stderr** and exit with a non-zero code.
3. Archive name template for rotation: `<archived dirname with dashes>*.tar.gz`
4. The script must be uploaded to a GitHub repository named **`task4_3`**.
5. The repository must contain exactly one file: `task4_3.sh` in the root folder.

---

## Environment Setup Guide

This section describes how to spin up a local Ubuntu 16.04 environment that matches the grader's setup so you can verify the solution before submission.

### Option A — Docker (recommended, works on Windows / macOS / Linux)

**Prerequisites:** Docker Desktop installed and running.

```bash
# 1. Pull the Ubuntu 16.04 image
docker pull ubuntu:16.04

# 2. Start a container
docker run -it --name backup-test ubuntu:16.04 /bin/bash
```

Inside the container:

```bash
# 3. Install prerequisites
apt-get update && apt-get install -y git

# 4. Clone the repository (replace with your actual URL)
git clone https://github.com/<your-username>/task4_3 /root/task4_3
cd /root/task4_3

# 5. Create a test directory with some content
mkdir -p /tmp/testdir && echo "hello" > /tmp/testdir/file.txt

# 6. Run the backup script — creates the first archive
bash task4_3.sh /tmp/testdir 3
ls /tmp/backups/

# 7. Run twice more to accumulate 3 backups
bash task4_3.sh /tmp/testdir 3
bash task4_3.sh /tmp/testdir 3
ls /tmp/backups/   # should show exactly 3 archives

# 8. Run a fourth time — the oldest archive must be deleted
bash task4_3.sh /tmp/testdir 3
ls /tmp/backups/   # still exactly 3 archives

# 9. Test error cases
bash task4_3.sh                       # too few args  → exit 1
bash task4_3.sh /no/such/dir 3        # missing dir   → exit 2
bash task4_3.sh /tmp/testdir abc      # invalid count → exit 3
bash task4_3.sh /tmp/testdir 3 extra  # too many args → exit 1
```

To re-use the container later:

```bash
docker start -ai backup-test
```

To start fresh:

```bash
docker rm backup-test
```

---

### Option B — Vagrant (closer to bare-metal)

**Prerequisites:** [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) installed.

Create a `Vagrantfile` in any working directory:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y git
  SHELL
end
```

```bash
# Start and SSH into the VM
vagrant up
vagrant ssh

# Then follow steps 4–9 from Option A above (inside the VM)
sudo -i
git clone https://github.com/<your-username>/task4_3 /root/task4_3
cd /root/task4_3
bash task4_3.sh /tmp/testdir 3
```

---

### Verification Checklist

| Check | Command | Expected result |
|---|---|---|
| Backup dir created automatically | `bash task4_3.sh /tmp/testdir 3 && ls /tmp/backups/` | Directory exists, archive present |
| Archive filename format | `ls /tmp/backups/` | Matches `tmp-testdir-<timestamp>.tar.gz` |
| Archive is valid gzip | `file /tmp/backups/tmp-testdir-*.tar.gz` | `gzip compressed data` |
| Rotation keeps exactly *n* files | Run script 4× with limit 3, then `ls /tmp/backups/ \| wc -l` | `3` |
| Too few arguments | `bash task4_3.sh /tmp/testdir` | Prints error to stderr, exits 1 |
| Too many arguments | `bash task4_3.sh /tmp/testdir 3 extra` | Prints error to stderr, exits 1 |
| Non-existent source directory | `bash task4_3.sh /no/such/dir 3` | Prints error to stderr, exits 2 |
| Non-numeric backup count | `bash task4_3.sh /tmp/testdir abc` | Prints error to stderr, exits 3 |

---

## Verification Procedure

### Environment

- **OS:** Ubuntu Xenial 16.04 Server
- **User:** `root`
- **Network:** internet access available

### Execution Rules

- The repository is cloned by URL (e.g. `https://github.com/user/task4_3`); a different repository name results in automatic failure.
- `task4_3.sh` is launched automatically from the repository root; a different script name or subdirectory location results in automatic failure.
- The script is run with multiple parameter combinations covering all error and success cases listed below.

---

## Expected Behavior

### Successful backup run

- `/tmp/backups/` is created if it does not exist.
- A new archive is created at `/tmp/backups/<dir>-<timestamp>.tar.gz`.
- After creation, archives for the given source directory are counted; any beyond the specified limit are deleted, oldest first.
- The script exits with code `0`.

### Error — wrong number of arguments

- Message printed to **stderr**.
- Script exits with a **non-zero** code.
- No backup is created.

### Error — source directory does not exist

- Message printed to **stderr**.
- Script exits with a **non-zero** code.
- No backup is created.

### Error — backup count argument is not a valid number

- Message printed to **stderr**.
- Script exits with a **non-zero** code.
- No backup is created.

> **Note:** All error messages must go to **stderr**. Output sent to stdout will not be detected by the checker and the script will be considered non-compliant.
