#!/bin/sh

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

# Set ownership for all project files to site owner (except writable dirs)
echo "Setting ownership of all files to $SITE_OWNER..."
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

# Set directory permissions (755 for most directories)
echo ""
echo "Setting directory permissions (755)..."
find . -type d -exec chmod 755 {} \;

# Set file permissions (644 for most files)
echo "Setting file permissions (644)..."
find . -type f -exec chmod 644 {} \;

# Set special permissions for storage and cache directories
echo ""
echo "Setting special permissions for writable directories..."

# Storage directories: 775 (rwxrwxr-x) - owner (www) and group (takehome) can write
for dir in $STORAGE_DIRS; do
    if [ -d "$dir" ]; then
        chmod 775 "$dir"
        # Set all files in these directories to 664 (rw-rw-r--)
        find "$dir" -type f -exec chmod 664 {} \;
        # Set all subdirectories to 775
        find "$dir" -type d -exec chmod 775 {} \;
        echo "  Set $dir to 775 (directories) and 664 (files)"
    fi
done

# Bootstrap cache: 775
if [ -d "bootstrap/cache" ]; then
    chmod 775 bootstrap/cache
    find bootstrap/cache -type f -exec chmod 664 {} \;
    find bootstrap/cache -type d -exec chmod 775 {} \;
    echo "  Set bootstrap/cache to 775 (directories) and 664 (files)"
fi

# Make storage/app/public accessible
if [ -d "storage/app/public" ]; then
    chmod 775 storage/app/public
    find storage/app/public -type f -exec chmod 664 {} \;
    find storage/app/public -type d -exec chmod 775 {} \;
    echo "  Set storage/app/public to 775 (directories) and 664 (files)"
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

# Ensure .env is readable only by owner (600)
if [ -f ".env" ]; then
    chmod 600 .env
    chown "$SITE_OWNER:$SITE_OWNER" .env
    echo "  Set .env to 600 (owner read/write only)"
fi

# Set permissions for public directory
if [ -d "public" ]; then
    chmod 755 public
    find public -type f -exec chmod 644 {} \;
    find public -type d -exec chmod 755 {} \;
    echo "  Set public directory permissions"
fi

echo ""
echo "✓ Permissions setup complete!"
echo ""
echo "Summary:"
echo "  - Most files/directories owned by: $SITE_OWNER:$SITE_OWNER (755/644)"
echo "  - Writable directories (storage, bootstrap/cache): $APACHE_USER:$SITE_OWNER"
echo "    - Directories: 775 (owner www and group takehome can write)"
echo "    - Files: 664 (owner www and group takehome can write)"
echo "  - Regular files: 644"
echo "  - Regular directories: 755"
echo "  - .env: 600 (secure, owned by $SITE_OWNER)"
echo ""
echo "The Apache user '$APACHE_USER' (owner) can now write to logs and cache directories."
echo "The site owner '$SITE_OWNER' (group) also has write access to these directories."
