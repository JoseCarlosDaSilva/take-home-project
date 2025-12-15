#!/usr/local/bin/bash

# Laravel Deployment Script
# This script should be run from the project root by the site owner (takehome)
# It handles composer, artisan, and frontend build tasks

set -e  # Exit on error

# Detect if colors are supported (check if output is a terminal)
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors)" -ge 8 ]; then
    # Colors are supported
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    # Colors not supported, use empty strings
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Get the script directory (project root)
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Ensure we use the current user's home directory for SSH/Git config
# This is important when using setuidgid or similar tools
CURRENT_USER=$(whoami)
CURRENT_HOME=$(eval echo ~$CURRENT_USER)

# Set HOME explicitly to avoid using root's home
export HOME="$CURRENT_HOME"

# Force git to use the current user's SSH config
# Get current user and home directory (important for setuidgid scenarios)
CURRENT_USER=$(whoami)
CURRENT_HOME=$(getent passwd "$CURRENT_USER" 2>/dev/null | cut -d: -f6)

# If getent fails, try eval as fallback
if [ -z "$CURRENT_HOME" ] || [ ! -d "$CURRENT_HOME" ]; then
    CURRENT_HOME=$(eval echo ~"$CURRENT_USER")
fi

# Force HOME to current user's home (prevents using root's config when using setuidgid)
export HOME="$CURRENT_HOME"

echo "========================================="
echo "Laravel Deployment Script"
echo "========================================="
echo "Working directory: $SCRIPT_DIR"
echo "User: $CURRENT_USER"
echo "Home: $CURRENT_HOME"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    printf "${RED}Error: .env file not found!${NC}\n"
    echo "Please create .env file from .env.sample before deploying."
    exit 1
fi

# Check if composer is available (try common paths if not in PATH)
COMPOSER_CMD="composer"
if ! command -v composer &> /dev/null; then
    # Try common installation paths
    if [ -f "/usr/local/bin/composer" ]; then
        COMPOSER_CMD="/usr/local/bin/composer"
        printf "${YELLOW}Found composer at: $COMPOSER_CMD${NC}\n"
    elif [ -f "/usr/bin/composer" ]; then
        COMPOSER_CMD="/usr/bin/composer"
        printf "${YELLOW}Found composer at: $COMPOSER_CMD${NC}\n"
    elif [ -f "$HOME/.composer/vendor/bin/composer" ]; then
        COMPOSER_CMD="$HOME/.composer/vendor/bin/composer"
        printf "${YELLOW}Found composer at: $COMPOSER_CMD${NC}\n"
    else
        printf "${RED}Error: Composer is not installed or not found${NC}\n"
        echo "Please install Composer or add it to PATH"
        exit 1
    fi
fi

# Check if php is available
PHP_CMD="php"
if ! command -v php &> /dev/null; then
    # Try common installation paths
    if [ -f "/usr/local/bin/php" ]; then
        PHP_CMD="/usr/local/bin/php"
        echo "${YELLOW}Found php at: $PHP_CMD${NC}"
    elif [ -f "/usr/bin/php" ]; then
        PHP_CMD="/usr/bin/php"
        echo "${YELLOW}Found php at: $PHP_CMD${NC}"
    else
        echo "${RED}Error: PHP is not installed or not found${NC}"
        echo "Please install PHP or add it to PATH"
        exit 1
    fi
fi

# Check if npm/node is available (for frontend build)
NPM_CMD="npm"
if ! command -v npm &> /dev/null; then
    # Try common installation paths
    if [ -f "/usr/local/bin/npm" ]; then
        NPM_CMD="/usr/local/bin/npm"
        printf "${YELLOW}Found npm at: $NPM_CMD${NC}\n"
        SKIP_FRONTEND=false
    elif [ -f "/usr/bin/npm" ]; then
        NPM_CMD="/usr/bin/npm"
        printf "${YELLOW}Found npm at: $NPM_CMD${NC}\n"
        SKIP_FRONTEND=false
    else
        printf "${YELLOW}Warning: npm is not installed or not found${NC}\n"
        echo "Frontend build will be skipped."
        SKIP_FRONTEND=true
    fi
else
    SKIP_FRONTEND=false
fi

echo "Starting deployment process..."
echo ""

# Step 1: Git pull (if in a git repository)
if [ -d ".git" ]; then
    printf "${GREEN}[1/7] Pulling latest changes from repository...${NC}\n"
    
    # Configure git to use current user's settings (important for setuidgid)
    export GIT_CONFIG_GLOBAL="$CURRENT_HOME/.gitconfig"
    export GIT_CONFIG_SYSTEM=/dev/null
    
    # Configure SSH to use current user's SSH config and keys
    # Try to use SSH config if it exists, otherwise use the deploy key directly
    if [ -f "$CURRENT_HOME/.ssh/config" ] && grep -q "github.com-takehome" "$CURRENT_HOME/.ssh/config" 2>/dev/null; then
        # Use SSH config (recommended approach with deploy key)
        export GIT_SSH_COMMAND="ssh -F $CURRENT_HOME/.ssh/config"
    elif [ -f "$CURRENT_HOME/.ssh/github_takehome_project" ]; then
        # Fallback: use deploy key directly
        export GIT_SSH_COMMAND="ssh -i $CURRENT_HOME/.ssh/github_takehome_project -o IdentitiesOnly=yes"
    else
        # No specific SSH config, use default but force current user's home
        export GIT_SSH_COMMAND="ssh -F $CURRENT_HOME/.ssh/config 2>/dev/null || ssh"
    fi
    
    # Try to pull, but continue if it fails (may not have SSH keys or remote access)
    if git pull origin main 2>&1; then
        printf "${GREEN}Successfully pulled latest changes.${NC}\n"
    else
        printf "${YELLOW}Warning: git pull failed. This is normal if:${NC}\n"
        printf "${YELLOW}  - SSH keys are not configured for user $CURRENT_USER${NC}\n"
        printf "${YELLOW}  - Repository uses SSH and user doesn't have access${NC}\n"
        printf "${YELLOW}  - Check: $CURRENT_HOME/.ssh/config and deploy keys${NC}\n"
        printf "${YELLOW}Continuing with current code...${NC}\n"
    fi
    echo ""
else
    printf "${YELLOW}[1/7] Not a git repository, skipping git pull...${NC}\n"
    echo ""
fi

# Step 2: Install/Update PHP dependencies
printf "${GREEN}[2/7] Installing PHP dependencies with Composer...${NC}\n"
$COMPOSER_CMD install --no-dev --optimize-autoloader --no-interaction || {
    printf "${RED}Error: Composer install failed!${NC}\n"
    exit 1
}
echo ""

# Step 3: Run database migrations
printf "${GREEN}[3/7] Running database migrations...${NC}\n"
$PHP_CMD artisan migrate --force --no-interaction || {
    printf "${RED}Error: Database migrations failed!${NC}\n"
    exit 1
}
echo ""

# Step 4: Clear and cache configuration
printf "${GREEN}[4/7] Optimizing Laravel...${NC}\n"
$PHP_CMD artisan config:clear
$PHP_CMD artisan cache:clear
$PHP_CMD artisan route:clear
$PHP_CMD artisan view:clear

# Cache configuration for production
$PHP_CMD artisan config:cache || {
    printf "${YELLOW}Warning: Config cache failed. Continuing...${NC}\n"
}
$PHP_CMD artisan route:cache || {
    printf "${YELLOW}Warning: Route cache failed. Continuing...${NC}\n"
}
$PHP_CMD artisan view:cache || {
    printf "${YELLOW}Warning: View cache failed. Continuing...${NC}\n"
}
echo ""

# Step 5: Build frontend assets
if [ "$SKIP_FRONTEND" = false ]; then
    printf "${GREEN}[5/7] Building frontend assets...${NC}\n"
    
    # Install npm dependencies if needed
    if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
        echo "Installing npm dependencies..."
        $NPM_CMD ci --legacy-peer-deps --no-audit || {
            printf "${YELLOW}Warning: npm ci failed, trying npm install...${NC}\n"
            $NPM_CMD install --legacy-peer-deps --no-audit || {
                printf "${RED}Error: npm install failed!${NC}\n"
                exit 1
            }
        }
        # Fix permissions for node_modules/.bin executables after install
        if [ -d "node_modules/.bin" ]; then
            chmod -R u+x node_modules/.bin/* 2>/dev/null || true
        fi
    fi
    
    # Ensure node_modules/.bin executables have correct permissions before build
    if [ -d "node_modules/.bin" ]; then
        chmod -R u+x node_modules/.bin/* 2>/dev/null || true
    fi
    
    # Build production assets
    $NPM_CMD run build || {
        printf "${RED}Error: Frontend build failed!${NC}\n"
        exit 1
    }
    echo ""
else
    printf "${YELLOW}[5/7] Skipping frontend build (npm not available)...${NC}\n"
    echo ""
fi

# Step 6: Ensure storage link exists
printf "${GREEN}[6/7] Ensuring storage link...${NC}\n"
$PHP_CMD artisan storage:link || {
    printf "${YELLOW}Warning: Storage link already exists or failed. Continuing...${NC}\n"
}
echo ""

# Step 7: Final optimizations
printf "${GREEN}[7/7] Running final optimizations...${NC}\n"
$PHP_CMD artisan optimize || {
    printf "${YELLOW}Warning: Optimize failed. Continuing...${NC}\n"
}
echo ""

# Summary
echo "========================================="
printf "${GREEN}✓ Deployment completed successfully!${NC}\n"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Run the permissions script if needed: ./scripts/fix-permissions.sh"
echo "  2. Test the application"
echo "  3. Check logs: tail -f storage/logs/laravel.log"
echo ""
