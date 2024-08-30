#!/bin/sh

# Detect OS
if [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
    OS="debian"
else
    OS="unknown"
fi

# Install dependencies based on OS
if [ "$OS" = "debian" ]; then
    apt-get update && apt-get install -y curl wget git build-essential ssh
else
    echo "Unsupported OS"
    exit 1
fi

mkdir -p ~/.ssh

if [ -n "$SSH_PRIVATE_KEY" ] && [ -n "$SSH_PUBLIC_KEY" ] && [ -n "$REPO_URL" ]; then
    echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    echo "$SSH_PUBLIC_KEY" > ~/.ssh/id_rsa.pub

    # Automatically accept the SSH fingerprint
    echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

    git init
    git remote add origin $REPO_URL
    git fetch origin
    git config --global user.email "dev.cluster@managbl.ai"
    git config --global user.name "dev-cluster"
    git add .
    git commit -m "init"
    git checkout dev
    git reset --hard origin/dev
    git branch -D master
fi

curl -fsSL https://code-server.dev/install.sh | sh

# Apply settings and restart code-server to ensure they take effect
mkdir -p ~/.local/share/code-server/User
cat << EOF > ~/.local/share/code-server/User/settings.json
{
  "workbench.colorTheme": "Dark+ (default dark)",
  "github.copilot.enable": true
}
EOF

# Start code-server, apply settings, and restart to ensure settings take effect
PORT=8080 code-server /app --bind-addr 0.0.0.0:8080 --auth none --disable-telemetry &
sleep 5
kill $(pgrep -f "code-server")
PORT=8080 code-server /app --bind-addr 0.0.0.0:8080 --auth none --disable-telemetry
