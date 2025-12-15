#!/usr/local/bin/bash
# Emergency opcache clearing script
# Run this if you're still seeing old code after deploy

set -e

PHP_CMD="php"

printf "Clearing opcache using multiple methods...\n\n"

# Method 1: Artisan command
printf "[1] Trying artisan opcache:clear...\n"
php artisan opcache:clear 2>&1 || printf "  (artisan command not available)\n"

# Method 2: Direct opcache_reset
printf "\n[2] Trying opcache_reset() via PHP...\n"
php -r "if (function_exists('opcache_reset')) { opcache_reset(); echo 'SUCCESS: Opcache cleared via opcache_reset()\n'; } else { echo 'opcache_reset() function not available\n'; }" 2>&1

# Method 3: PHP-FPM reload (FreeBSD)
printf "\n[3] Trying PHP-FPM reload...\n"
if [ -f /usr/local/etc/rc.d/php-fpm ]; then
    sudo /usr/local/etc/rc.d/php-fpm reload 2>&1 && printf "SUCCESS: PHP-FPM reloaded\n" || printf "Failed to reload PHP-FPM (may need sudo)\n"
else
    printf "PHP-FPM service script not found at /usr/local/etc/rc.d/php-fpm\n"
fi

# Method 4: Kill and restart PHP-FPM processes (last resort)
printf "\n[4] Checking for PHP-FPM processes...\n"
PHP_FPM_PIDS=$(pgrep -f php-fpm 2>/dev/null || true)
if [ -n "$PHP_FPM_PIDS" ]; then
    printf "Found PHP-FPM processes: $PHP_FPM_PIDS\n"
    printf "To restart PHP-FPM, run: sudo /usr/local/etc/rc.d/php-fpm restart\n"
else
    printf "No PHP-FPM processes found\n"
fi

printf "\n=== Verification ===\n"
php -r "require 'vendor/autoload.php'; echo 'EasyPostClient exists: ' . (class_exists('EasyPost\\EasyPostClient') ? 'YES' : 'NO') . '\n'; echo 'EasyPost (old) exists: ' . (class_exists('EasyPost\\EasyPost') ? 'YES (PROBLEM!)' : 'NO (correct)') . '\n';"

