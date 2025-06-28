#!/bin/bash

# Script to run npm install on all directories containing package.json
# inside ~/www/ but excluding node_modules, vendor, and other dependency directories

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

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    log_error "npm not found. Please install Node.js and npm first."
    exit 1
fi

# Target directory
TARGET_DIR="$HOME/www"

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    log_error "Directory $TARGET_DIR not found."
    exit 1
fi

log_info "Searching for package.json files inside $TARGET_DIR..."

# Arrays to store processed directories
successful_installs=()
failed_installs=()

# Find all package.json files, excluding node_modules, vendor, etc.
while IFS= read -r -d '' package_file; do
    # Get directory from package.json file
    project_dir=$(dirname "$package_file")
    
    log_info "Found package.json in: $project_dir"
    
    # Change to project directory
    cd "$project_dir" || {
        log_error "Cannot enter directory $project_dir"
        failed_installs+=("$project_dir")
        continue
    }
    
    # Check if node_modules directory already exists
    if [ -d "node_modules" ]; then
        log_warning "node_modules directory already exists in $project_dir. Skipping..."
        continue
    fi
    
    log_info "Running npm install in: $project_dir"
    
    # Run npm install
    if npm install --silent; then
        log_success "npm install successful in: $project_dir"
        successful_installs+=("$project_dir")
    else
        log_error "npm install failed in: $project_dir"
        failed_installs+=("$project_dir")
    fi
    
    echo "----------------------------------------"
    
done < <(find "$TARGET_DIR" -name "package.json" -type f \
    -not -path "*/node_modules/*" \
    -not -path "*/vendor/*" \
    -not -path "*/bower_components/*" \
    -not -path "*/.git/*" \
    -not -path "*/cache/*" \
    -not -path "*/tmp/*" \
    -not -path "*/temp/*" \
    -not -path "*/.npm/*" \
    -not -path "*/storage/*" \
    -not -path "*/dist/*" \
    -not -path "*/web/*" \
    -not -path "*/build/*" \
    -not -path "*/rsud-medifirst/*" \
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
    log_warning "No package.json files found or all already have node_modules directories."
fi

log_info "Done!"
