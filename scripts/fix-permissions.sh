#!/usr/local/bin/bash

# Laravel Permissions Fix Script for FreeBSD Apache/PHP-FPM
# This script sets correct ownership and permissions for Laravel directories
# Apache user: www
# Site owner: takehome

APACHE_USER="www"
SITE_OWNER="takehome"

echo "Setting Laravel permissions for FreeBSD Apache/PHP-FPM..."
echo "Apache user: $APACHE_USER"
echo "Site owner: $SITE_OWNER"
echo ""

# Get the script directory (project root)
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Change to project root
cd "$SCRIPT_DIR" || exit 1

echo "Working directory: $SCRIPT_DIR"
echo ""

# Set ownership for all project files to site owner (will adjust writable dirs later)
echo "Setting ownership of all files to $SITE_OWNER:$SITE_OWNER..."
chown -R "$SITE_OWNER:$SITE_OWNER" .

# Directories that need to be writable by Apache
STORAGE_DIRS="storage/logs storage/framework/cache storage/framework/sessions storage/framework/views storage/app/public bootstrap/cache"

# Create directories if they don't exist
for dir in $STORAGE_DIRS; do
    if [ ! -d "$dir" ]; then
        echo "Creating directory: $dir"
        mkdir -p "$dir"
    fi
done

# Set ownership of storage and bootstrap/cache to apache user:site owner group
# Owner: www (Apache can write)
# Group: takehome (site owner can also access)
echo ""
echo "Setting ownership of writable directories to $APACHE_USER:$SITE_OWNER..."
chown -R "$APACHE_USER:$SITE_OWNER" storage
chown -R "$APACHE_USER:$SITE_OWNER" bootstrap/cache

# Set permissions for regular directories and files (excluding writable dirs)
echo ""
echo "Setting permissions for regular files and directories..."
find . -type d ! -path "./storage/*" ! -path "./bootstrap/cache/*" -exec chmod 755 {} \;
find . -type f ! -path "./storage/*" ! -path "./bootstrap/cache/*" -exec chmod 644 {} \;

# Set special permissions for storage and cache directories
echo ""
echo "Setting special permissions for writable directories..."

# Storage directories: 775 (rwxrwxr-x) - owner (www) and group (takehome) can write
# Files: 664 (rw-rw-r--) - owner (www) and group (takehome) can write
for dir in $STORAGE_DIRS; do
    if [ -d "$dir" ]; then
        # Set directory permissions to 775
        find "$dir" -type d -exec chmod 775 {} \;
        # Set file permissions to 664
        find "$dir" -type f -exec chmod 664 {} \;
        echo "  Set $dir: directories to 775, files to 664"
    fi
done

# Bootstrap cache: 775 for dirs, 664 for files
if [ -d "bootstrap/cache" ]; then
    find bootstrap/cache -type d -exec chmod 775 {} \;
    find bootstrap/cache -type f -exec chmod 664 {} \;
    echo "  Set bootstrap/cache: directories to 775, files to 664"
fi

# Set permissions for artisan and scripts (executable)
echo ""
echo "Setting executable permissions..."
if [ -f "artisan" ]; then
    chmod 755 artisan
    chown "$SITE_OWNER:$SITE_OWNER" artisan
    echo "  Set artisan to 755"
fi

# Make scripts executable
if [ -d "scripts" ]; then
    find scripts -type f -name "*.sh" -exec chmod 755 {} \;
    find scripts -type f -name "*.sh" -exec chown "$SITE_OWNER:$SITE_OWNER" {} \;
    echo "  Set script files to 755"
fi

# Ensure .env is readable by owner and group (640)
# Owner: takehome (can read/write)
# Group: www (PHP-FPM needs to read)
if [ -f ".env" ]; then
    chmod 640 .env
    chown "$SITE_OWNER:$APACHE_USER" .env
    echo "  Set .env to 640 (owner read/write, group read) - owned by $SITE_OWNER:$APACHE_USER"
fi

# Set permissions for public directory
if [ -d "public" ]; then
    find public -type d -exec chmod 755 {} \;
    find public -type f -exec chmod 644 {} \;
    echo "  Set public directory: directories to 755, files to 644"
fi

echo ""
echo "✓ Permissions setup complete!"
echo ""
echo "Summary:"
echo "  - Regular files/directories: $SITE_OWNER:$SITE_OWNER (755/644)"
echo "  - Writable directories (storage, bootstrap/cache): $APACHE_USER:$SITE_OWNER"
echo "    - Directories: 775 (owner www and group takehome can write)"
echo "    - Files: 664 (owner www and group takehome can write)"
echo "  - Executable files (artisan, scripts): $SITE_OWNER:$SITE_OWNER (755)"
echo "  - .env: $SITE_OWNER:$APACHE_USER (640, owner read/write, group read)"
echo ""
echo "The Apache user '$APACHE_USER' (owner) can now write to logs and cache directories."
echo "The site owner '$SITE_OWNER' (group) also has write access to these directories."
