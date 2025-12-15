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
CURRENT_HOME=$(getent passwd "$CURRENT_USER" 2>/dev/null | cut -d: -f6)

# If getent fails, try eval as fallback
if [ -z "$CURRENT_HOME" ] || [ ! -d "$CURRENT_HOME" ]; then
    CURRENT_HOME=$(eval echo ~"$CURRENT_USER")
fi

# Set HOME explicitly to avoid using root's home (critical for setuidgid)
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
    # This is critical when using setuidgid - forces use of current user's SSH config
    if [ -f "$CURRENT_HOME/.ssh/config" ] && grep -q "github.com-takehome" "$CURRENT_HOME/.ssh/config" 2>/dev/null; then
        # Use SSH config (recommended approach with deploy key)
        # The SSH config should define Host github.com-takehome with the correct IdentityFile
        export GIT_SSH_COMMAND="ssh -F $CURRENT_HOME/.ssh/config"
        
        # Check if remote URL needs to be updated to use the SSH alias
        CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
        if echo "$CURRENT_REMOTE" | grep -q "^git@github.com:" && ! echo "$CURRENT_REMOTE" | grep -q "github.com-takehome"; then
            # Remote uses standard github.com, update to use alias
            NEW_REMOTE=$(echo "$CURRENT_REMOTE" | sed 's|git@github.com:|git@github.com-takehome:|')
            printf "${YELLOW}Updating git remote URL to use SSH alias...${NC}\n"
            git remote set-url origin "$NEW_REMOTE" 2>/dev/null || true
        fi
    else
        # No SSH config alias found, use default SSH config
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

# Ensure autoloader is up to date (important for packages like EasyPost)
printf "Regenerating Composer autoloader...\n"
$COMPOSER_CMD dump-autoload --optimize --no-interaction || {
    printf "${YELLOW}Warning: Autoloader regeneration failed, continuing...${NC}\n"
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

# Ensure cache directories exist and have correct permissions
CACHE_DIRS="storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache"
for dir in $CACHE_DIRS; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" 2>/dev/null || true
    fi
    # Make sure current user can write to cache directories
    chmod -R u+w "$dir" 2>/dev/null || true
done

# Try to clear caches (may fail if permissions aren't perfect, that's ok)
$PHP_CMD artisan config:clear 2>&1 || {
    printf "${YELLOW}Warning: Config clear failed (may need permissions fix). Continuing...${NC}\n"
}
$PHP_CMD artisan cache:clear 2>&1 || {
    printf "${YELLOW}Warning: Cache clear failed (may need permissions fix). Continuing...${NC}\n"
}
$PHP_CMD artisan route:clear 2>&1 || {
    printf "${YELLOW}Warning: Route clear failed (may need permissions fix). Continuing...${NC}\n"
}
$PHP_CMD artisan view:clear 2>&1 || {
    printf "${YELLOW}Warning: View clear failed (may need permissions fix). Continuing...${NC}\n"
}

# Cache configuration for production
$PHP_CMD artisan config:cache 2>&1 || {
    printf "${YELLOW}Warning: Config cache failed. Continuing...${NC}\n"
}
$PHP_CMD artisan route:cache 2>&1 || {
    printf "${YELLOW}Warning: Route cache failed. Continuing...${NC}\n"
}
$PHP_CMD artisan view:cache 2>&1 || {
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
    fi
    
    # ALWAYS fix permissions for ALL executables in node_modules
    # This includes node_modules/.bin AND packages like @esbuild/*/bin/esbuild
    if [ -d "node_modules" ]; then
        printf "Fixing permissions for node_modules executables...\n"
        # Fix node_modules/.bin executables
        if [ -d "node_modules/.bin" ]; then
            find node_modules/.bin -type f -exec chmod +x {} \; 2>/dev/null || true
        fi
        # Fix executables in package bin directories (e.g., @esbuild/freebsd-x64/bin/esbuild)
        find node_modules -type f -path "*/bin/*" -exec chmod +x {} \; 2>/dev/null || true
        # Also check for common executable patterns
        find node_modules -type f \( -name "esbuild" -o -name "vite" -o -name "node" \) -exec chmod +x {} \; 2>/dev/null || true
        printf "Permissions fixed.\n"
    else
        printf "${YELLOW}Warning: node_modules directory not found!${NC}\n"
    fi
    
    # Build production assets
    printf "Building frontend assets...\n"
    $NPM_CMD run build || {
        printf "${YELLOW}Build failed, fixing all executable permissions and retrying...${NC}\n"
        # Fix all executables more aggressively
        find node_modules -type f -path "*/bin/*" -exec chmod +x {} \; 2>/dev/null || true
        find node_modules/.bin -type f -exec chmod +x {} \; 2>/dev/null || true
        find node_modules/@esbuild -type f -name "esbuild" -exec chmod +x {} \; 2>/dev/null || true
        
        printf "Retrying build...\n"
        $NPM_CMD run build || {
            printf "${RED}Error: Frontend build failed after permission fixes!${NC}\n"
            printf "${YELLOW}Please check:${NC}\n"
            printf "  1. node_modules/.bin/vite permissions\n"
            printf "  2. node_modules/@esbuild/*/bin/esbuild permissions\n"
            printf "  3. Run: find node_modules -type f -executable -ls${NC}\n"
            exit 1
        }
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

# Clear and rebuild autoloader cache
$COMPOSER_CMD dump-autoload --optimize --no-interaction || {
    printf "${YELLOW}Warning: Autoloader dump failed. Continuing...${NC}\n"
}

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
