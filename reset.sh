#!/bin/bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
CERTS_DIR="$SCRIPT_DIR/docker/certificates"
CODE_DIR="$SCRIPT_DIR/code"

echo "Warning: This will remove all of your existing panel and wings code, certificates, and data. This action cannot be undone."
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting reset."
    exit 0
fi

# Stop beak containers if they're running and remove volumes
docker compose down -v

for REPO in "panel" "wings"
do
  if [ -d "$CODE_DIR/$REPO" ]; then
    echo "removing existing $REPO repository from: $CODE_DIR/$REPO"
    rm -rf "$CODE_DIR/$REPO"
  else
    echo "no existing $REPO repository found in: $CODE_DIR/$REPO"
  fi
done

if [ -d "$CERTS_DIR" ]; then
    echo "removing existing certificates from: $CERTS_DIR"
    for CERT_FILE in "reviactyl.test-key.pem" "reviactyl.test.pem" "root_ca.pem"; do
        if [ -f "$CERTS_DIR/$CERT_FILE" ]; then
            rm -f "$CERTS_DIR/$CERT_FILE"
            echo "✅ removed $CERT_FILE"
        else
            echo "✅ no existing $CERT_FILE found in $CERTS_DIR; skipping..."
        fi
    done
else
    echo "no existing certificates found in: $CERTS_DIR"
fi

echo ""
if [ ! -f "/etc/hosts" ]; then
    echo "no system hosts file found, please configure your system manually."
else
    for DOMAIN in "reviactyl.test" "wings.reviactyl.test" "minio.reviactyl.test" "s3.minio.reviactyl.test"; do
        ESCAPED_DOMAIN=$(echo $DOMAIN | sed "s/\./\\\./g")
        if grep -q -E "127\.0\.0\.1\s+$ESCAPED_DOMAIN\s*$" /etc/hosts; then
            echo "✅ removing existing entry for \"$DOMAIN\" from system hosts file"
            sudo sed -i.bak "/127\.0\.0\.1\s\+$ESCAPED_DOMAIN\s*$/d" /etc/hosts || exit 1
        else
            echo "✅ no existing entry for \"$DOMAIN\" found in system hosts file; skipping..."
        fi
    done
fi

if [ -d "/var/lib/reviactyl" ]; then
    echo "removing existing data directory from: /var/lib/reviactyl"
    sudo rm -rf /var/lib/reviactyl
else
    echo "no existing data directory found in: /var/lib/reviactyl"
fi

echo "Reset complete. You can now run setup.sh to reinitialize the environment or delete this folder."
echo "optionally, remove the beak alias from your shell configuration:"
echo ""
echo "bash:"
echo "sed -i.bak '/alias beak=/d' ~/.bash_profile"
echo ""
echo "zsh:"
echo "sed -i.bak '/alias beak=/d' ~/.zshrc"