#!/usr/bin/env bash
# Set up Python, uv, and R on Debian. Debian counterpart of initvm-ubu-py-r.yaml, based on:
#   https://greg.pronghorns.net/research-notebook/computing/virtual-machine-setup/
#
# R and R packages come prebuilt from Debian's own repositories (r-base, r-cran-*).
# Add more with apt, e.g.:  sudo apt-get install r-cran-data.table
#
# Usage:  sudo bash setup-debian.sh [username]   (default: the user who ran sudo)

set -euo pipefail # Stop on first/any error

# Require root
if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0 [username]" >&2
  exit 1
fi
# Choose uv user
TARGET_USER="${1:-${SUDO_USER:-}}"
# Refuse empty or root user
if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
  echo "Give a non-root username: sudo bash $0 <username>" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

# --- Python ---
apt-get install -y python3-full python3-pip python3-pip-whl curl ca-certificates

# --- R + prebuilt tidyverse from Debian (note that these may lag behind CRAN) ---
apt-get install -y r-base r-base-dev r-recommended r-cran-tidyverse

# --- uv for the target user ---
su - "$TARGET_USER" -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'

# --- Optional: prebuilt CRAN packages from Posit Public Package Manager -------
# Use this to get current CRAN versions as binaries via install.packages().
# Posit supports Debian 13 (trixie) on x86_64 only. Confirm the URL for your
# system at https://packagemanager.posit.co/client/#/repos/cran/setup
# Some binaries need runtime system libraries; install them with apt if a
# package fails to load (the error names the missing .so file).
#
# This writes the settings to the user's ~/.Rprofile:
#
# cat >> "$(getent passwd "$TARGET_USER" | cut -d: -f6)/.Rprofile" <<'EOF'
# # Posit Public Package Manager: prebuilt Linux binaries
# options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/trixie/latest"))
# # Send R version/platform so the server returns Linux binaries
# options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(),
#   paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))
# EOF
# chown "$TARGET_USER": "$(getent passwd "$TARGET_USER" | cut -d: -f6)/.Rprofile"

echo "Done. $(R --version | head -n 1); $(python3 --version). Open a new shell for uv."