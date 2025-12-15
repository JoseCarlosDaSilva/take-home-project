#!/bin/sh

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

echo "========================================="
echo "Laravel Deployment Script"
echo "========================================="
echo "Working directory: $SCRIPT_DIR"
echo "User: $(whoami)"
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
    echo "${GREEN}[1/7] Pulling latest changes from repository...${NC}"
    git pull origin main || {
        echo "${YELLOW}Warning: git pull failed. Continuing with current code...${NC}"
    }
    echo ""
else
    echo "${YELLOW}[1/7] Not a git repository, skipping git pull...${NC}"
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
echo "${GREEN}[3/7] Running database migrations...${NC}"
$PHP_CMD artisan migrate --force --no-interaction || {
    echo "${RED}Error: Database migrations failed!${NC}"
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
