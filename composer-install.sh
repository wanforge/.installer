#!/bin/bash

# Script to run composer install on all directories containing composer.json
# inside ~/www/ but excluding vendor, node_modules, and other dependency directories

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for colored logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if composer is installed
if ! command -v composer &> /dev/null; then
    log_error "Composer not found. Please install composer first."
    exit 1
fi

# Target directory
TARGET_DIR="$HOME/www"

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    log_error "Directory $TARGET_DIR not found."
    exit 1
fi

log_info "Searching for composer.json files inside $TARGET_DIR..."

# Arrays to store processed directories
successful_installs=()
failed_installs=()

# Find all composer.json files, excluding vendor, node_modules, etc.
while IFS= read -r -d '' composer_file; do
    # Get directory from composer.json file
    project_dir=$(dirname "$composer_file")
    
    log_info "Found composer.json in: $project_dir"
    
    # Change to project directory
    cd "$project_dir" || {
        log_error "Cannot enter directory $project_dir"
        failed_installs+=("$project_dir")
        continue
    }
    
    # Check for doku/jokul-php-library in composer.json and remove it if exists
    if [ -f "composer.json" ]; then
        if grep -q '"doku/jokul-php-library"' composer.json; then
            log_warning "Found 'doku/jokul-php-library' dependency in $project_dir. Removing it..."
            
            # Create backup of composer.json
            cp composer.json composer.json.backup
            
            # Remove the doku/jokul-php-library line using sed
            # This handles various formats: with/without trailing comma, different spacing
            sed -i '/[[:space:]]*"doku\/jokul-php-library"[[:space:]]*:[[:space:]]*"[^"]*"[[:space:]]*,\?[[:space:]]*/d' composer.json
            
            # Clean up any potential double commas or trailing commas before closing braces
            sed -i 's/,\([[:space:]]*\),/,\1/g' composer.json
            sed -i 's/,\([[:space:]]*}\)/\1/g' composer.json
            
            log_info "Removed 'doku/jokul-php-library' from composer.json"
        fi
    fi
    
    # Check if vendor directory already exists
    if [ -d "vendor" ]; then
        log_warning "Vendor directory already exists in $project_dir. Running composer update instead..."
        
        # Run composer update
        if composer update --no-interaction --optimize-autoloader --with-all-dependencies; then
            log_success "Composer update successful in: $project_dir"
            
            # Commit and push composer.lock if it exists and we're in a git repository
            if [ -f "composer.lock" ] && git rev-parse --git-dir > /dev/null 2>&1; then
                if git add composer.lock && git commit --no-gpg-sign -m "Update composer.lock after composer update in $(basename "$project_dir")"; then
                    log_success "Committed composer.lock for: $project_dir"
                    if git push; then
                        log_success "Pushed changes for: $project_dir"
                    else
                        log_warning "Failed to push changes for: $project_dir"
                    fi
                else
                    log_warning "Failed to commit composer.lock for: $project_dir (may already be up to date)"
                fi
            fi
            
            successful_installs+=("$project_dir")
        else
            log_warning "Composer update failed in: $project_dir. Trying fresh install..."
            
            # Remove composer.lock and vendor directory for fresh install
            if [ -f "composer.lock" ]; then
                log_info "Removing composer.lock for fresh install"
                rm composer.lock
            fi
            
            if [ -d "vendor" ]; then
                log_info "Removing vendor directory for fresh install"
                rm -rf vendor
            fi
            
            # Try fresh composer install
            if composer install --no-interaction --optimize-autoloader; then
                log_success "Fresh composer install successful in: $project_dir"
                
                # Commit and push composer.lock if it exists and we're in a git repository
                if [ -f "composer.lock" ] && git rev-parse --git-dir > /dev/null 2>&1; then
                    if git add composer.lock && git commit --no-gpg-sign -m "Add composer.lock after fresh composer install in $(basename "$project_dir")"; then
                        log_success "Committed composer.lock for: $project_dir"
                        if git push; then
                            log_success "Pushed changes for: $project_dir"
                        else
                            log_warning "Failed to push changes for: $project_dir"
                        fi
                    else
                        log_warning "Failed to commit composer.lock for: $project_dir (may already be up to date)"
                    fi
                fi
                
                successful_installs+=("$project_dir")
            else
                log_error "Fresh composer install also failed in: $project_dir"
                failed_installs+=("$project_dir")
            fi
        fi
    else
        log_info "Running composer install in: $project_dir"
        
        # Run composer install
        if composer install --no-interaction --optimize-autoloader; then
            log_success "Composer install successful in: $project_dir"
            
            # Commit and push composer.lock if it exists and we're in a git repository
            if [ -f "composer.lock" ] && git rev-parse --git-dir > /dev/null 2>&1; then
                if git add composer.lock && git commit --no-gpg-sign -m "Add composer.lock after composer install in $(basename "$project_dir")"; then
                    log_success "Committed composer.lock for: $project_dir"
                    if git push; then
                        log_success "Pushed changes for: $project_dir"
                    else
                        log_warning "Failed to push changes for: $project_dir"
                    fi
                else
                    log_warning "Failed to commit composer.lock for: $project_dir (may already be up to date)"
                fi
            fi
            
            successful_installs+=("$project_dir")
        else
            log_error "Composer install failed in: $project_dir"
            failed_installs+=("$project_dir")
        fi
    fi
    
    echo "----------------------------------------"
    
done < <(find "$TARGET_DIR" -name "composer.json" -type f \
    -not -path "*/vendor/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/bower_components/*" \
    -not -path "*/.git/*" \
    -not -path "*/cache/*" \
    -not -path "*/tmp/*" \
    -not -path "*/temp/*" \
    -not -path "*/.composer/*" \
    -not -path "*/storage/*" \
    -not -path "*/web/*" \
    -not -path "*/*medifirst/*" \
    -print0)

# Display summary
echo ""
log_info "=== SUMMARY ==="

if [ ${#successful_installs[@]} -gt 0 ]; then
    log_success "Successfully installed (${#successful_installs[@]} directories):"
    for dir in "${successful_installs[@]}"; do
        echo "  ✓ $dir"
    done
fi

if [ ${#failed_installs[@]} -gt 0 ]; then
    log_error "Failed to install (${#failed_installs[@]} directories):"
    for dir in "${failed_installs[@]}"; do
        echo "  ✗ $dir"
    done
fi

if [ ${#successful_installs[@]} -eq 0 ] && [ ${#failed_installs[@]} -eq 0 ]; then
    log_warning "No composer.json files found or all already have vendor directories."
fi

log_info "Done!"
