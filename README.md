# Smart Application Log Rotator and Disk Guard

A Linux operations portfolio project that demonstrates application-log generation, size-based rotation, gzip compression, retention, and a disk-usage-triggered emergency rotation workflow.

This is a local lab project designed to practise Bash, `df`, `awk`, `logrotate`, process control, and operational troubleshooting. It is not a replacement for centralized production logging or monitoring.

## Problem

Application logs grow continuously. Without rotation and retention controls, they can consume disk space, make troubleshooting slower, and eventually affect application availability.

## Components

| File | Purpose |
|---|---|
| `app_generator.sh` | Generates timestamped sample login, payment, and warning events |
| `app_logrotate.conf` | Portable logrotate template for compression and retention |
| `app_guard.sh` | Checks root-filesystem usage and forces rotation at a configured threshold |

## Requirements

- Linux or WSL
- Bash
- `logrotate`
- `awk`, `df`, `mktemp`, and standard GNU utilities
- `sudo` permission when logrotate requires elevated access

On Debian or Ubuntu:

```bash
sudo apt update
sudo apt install -y logrotate
```

On Amazon Linux, Fedora, or RHEL:

```bash
sudo dnf install -y logrotate
```

## Run the log generator

```bash
chmod +x app_generator.sh app_guard.sh
./app_generator.sh
```

The script creates `logs/app.log` relative to the repository directory. Stop it with `Ctrl+C`.

To generate events more quickly or slowly:

```bash
LOG_INTERVAL=0.1 ./app_generator.sh
```

## Check the guard safely

The default disk threshold is 90%. A dry run shows what would happen without calling `sudo logrotate`:

```bash
DISK_THRESHOLD=0 DRY_RUN=1 ./app_guard.sh
```

## Force a real rotation test

First generate enough log data, then run:

```bash
DISK_THRESHOLD=0 ./app_guard.sh
```

The guard renders the checked-in template with the repository's absolute log path before calling `logrotate`. After rotation, inspect the results:

```bash
ls -lh logs/
gzip -l logs/*.gz
```

Expected files may include:

```text
app.log
app.log.1.gz
app.log.2.gz
app.log.3.gz
```

## Configuration

The template rotates the log when it reaches 10 KiB, retains three archives, compresses older files, ignores missing or empty logs, and uses `copytruncate` so the generator can continue writing without being restarted.

Environment variables supported by the scripts:

| Variable | Default | Description |
|---|---:|---|
| `LOG_INTERVAL` | `0.2` | Seconds between generated event batches |
| `DISK_THRESHOLD` | `90` | Root-filesystem percentage that triggers rotation |
| `DRY_RUN` | `0` | Set to `1` to show the action without running logrotate |
| `LOG_FILE` | `logs/app.log` | Optional absolute or relative log-file override |

## Operational limitations

- The project monitors only the root filesystem.
- `copytruncate` can theoretically lose a small number of log lines during rotation.
- The guard is run manually; production scheduling would use a systemd timer, cron, or monitoring system.
- Production systems normally ship logs to centralized platforms and add alerting, access control, and backup policies.

## What I learned

- How `df -P` output can be parsed safely for an automation threshold.
- How logrotate applies size, retention, compression, and missing-file policies.
- Why application and rotation paths must remain consistent.
- How to make Bash scripts independent of a specific username or home directory.
- How a dry-run mode makes operational automation safer to test.
