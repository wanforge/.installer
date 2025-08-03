# Project Installer Scripts

A collection of automated scripts to install dependencies for PHP (Composer) and Node.js (npm) projects in bulk.

## Overview

This repository contains utility scripts that automatically search for and install dependencies in multiple projects within a specified directory structure. The scripts are designed to work with projects located in `~/www/` directory.

## Scripts

### 1. `composer-install.sh` - Composer Dependencies Installer

Automatically finds all `composer.json` files and runs `composer install` on each project.

### 2. `npm-install.sh` - npm Dependencies Installer  

Automatically finds all `package.json` files and runs `npm install` on each project.

## Features

- **🔍 Automatic Discovery**: Recursively searches for dependency files (`composer.json` or `package.json`)
- **🚫 Smart Exclusions**: Skips common directories like `vendor/`, `node_modules/`, `.git/`, etc.
- **✅ Duplicate Prevention**: Checks if dependencies are already installed before running
- **🎨 Colored Output**: Color-coded logging for better readability
- **📊 Summary Report**: Shows successful and failed installations at the end
- **⚡ Error Handling**: Graceful handling of permission issues and failed installations
- **🔄 Auto Git Commit**: Automatically commits lock files (`composer.lock` / `package-lock.json`) after successful installations
- **🧹 Dependency Cleanup**: Removes problematic dependencies like `doku/jokul-php-library` from composer.json

## Prerequisites

### For Composer Script (`composer-install.sh`)

- **PHP** installed on your system
- **Composer** globally installed and accessible via command line
- **Git** installed and configured (for automatic lock file commits)
- Projects with `composer.json` files

### For npm Script (`npm-install.sh`)

- **Node.js** and **npm** installed on your system
- **Git** installed and configured (for automatic lock file commits)
- Projects with `package.json` files

## Installation

1. Clone or download the scripts to your desired location:

   ```bash
   git clone <repository-url>
   cd .installer
   ```

2. Make the scripts executable:

   ```bash
   chmod +x composer-install.sh
   chmod +x npm-install.sh
   ```

## Usage

### Running Composer Installer

```bash
./composer-install.sh
```

### Running npm Installer

```bash
./npm-install.sh
```

### Example Output

```bash
[INFO] Searching for composer.json files inside /home/user/www...
[INFO] Found composer.json in: /home/user/www/project1
[INFO] Running composer install in: /home/user/www/project1
[SUCCESS] Composer install successful in: /home/user/www/project1
[SUCCESS] Committed composer.lock for: /home/user/www/project1
----------------------------------------
[INFO] Found composer.json in: /home/user/www/project2
[WARNING] Vendor directory already exists in /home/user/www/project2. Running composer update instead...
[SUCCESS] Composer update successful in: /home/user/www/project2
[SUCCESS] Committed composer.lock for: /home/user/www/project2
----------------------------------------

[INFO] === SUMMARY ===
[SUCCESS] Successfully installed (2 directories):
  ✓ /home/user/www/project1
  ✓ /home/user/www/project2
[INFO] Done!
```

## Directory Structure

The scripts work with the following directory structure:

```text
~/www/
├── project1/
│   ├── composer.json
│   └── src/
├── project2/
│   ├── package.json
│   └── src/
├── project3/
│   ├── composer.json
│   ├── package.json
│   └── vendor/ (will be skipped)
└── project4/
    └── node_modules/ (will be skipped)
```

## Excluded Directories

The scripts automatically exclude the following directories to prevent unnecessary processing:

### Common Exclusions

- `vendor/` - PHP dependencies
- `node_modules/` - Node.js dependencies  
- `bower_components/` - Bower dependencies
- `.git/` - Git repository data
- `cache/`, `tmp/`, `temp/` - Temporary files
- `storage/` - Application storage

### npm Script Additional Exclusions

- `dist/` - Built/compiled files
- `build/` - Build artifacts
- `.npm/` - npm cache directory
- `web/` - Web assets directory

### Custom Exclusions

- `rsud-medifirst/` - Project-specific exclusion

## Configuration

### Changing Target Directory

To change the target directory from `~/www/`, edit the `TARGET_DIR` variable in the scripts:

```bash
# Change this line in composer-install.sh or npm-install.sh
TARGET_DIR="$HOME/www"
# To your desired path, for example:
TARGET_DIR="/var/www"
```

### Adding More Exclusions

To exclude additional directories, add them to the find command:

```bash
# Add more -not -path patterns
-not -path "*/your-custom-dir/*" \
```

## Error Handling

The scripts handle various error scenarios:

- **Missing dependencies**: Checks if Composer/npm is installed
- **Missing target directory**: Verifies that `~/www/` exists
- **Permission issues**: Handles directories that cannot be accessed
- **Installation failures**: Tracks and reports failed installations
- **Already installed**: Skips projects that already have dependencies

## Git Integration

### Automatic Lock File Commits

Both scripts automatically commit lock files after successful dependency installations:

- **`composer-install.sh`**: Commits `composer.lock` files
- **`npm-install.sh`**: Commits `package-lock.json` files

### How It Works

1. After successful installation/update, the script checks if:
   - A lock file exists (`composer.lock` or `package-lock.json`)
   - The project directory is a git repository
2. If both conditions are met, it automatically:
   - Adds the lock file to git staging
   - Commits with a descriptive message
   - Displays success/warning messages

### Git Commit Messages

The scripts use descriptive commit messages:

- `"Add composer.lock after composer install in {project-name}"`
- `"Update composer.lock after composer update in {project-name}"`
- `"Add package-lock.json after npm install in {project-name}"`
- `"Update package-lock.json after npm update in {project-name}"`

### Prerequisites for Git Integration

- Projects must be git repositories (have `.git` directory)
- Git must be configured with user name and email
- Appropriate git permissions for the project directories

```bash
# Configure git if not already done
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Logging

The scripts use color-coded logging for different message types:

- 🔵 **[INFO]** - General information (Blue)
- 🟢 **[SUCCESS]** - Successful operations (Green)  
- 🟡 **[WARNING]** - Warnings and skipped items (Yellow)
- 🔴 **[ERROR]** - Errors and failures (Red)

## Troubleshooting

### Common Issues

1. **Permission Denied**

   ```bash
   chmod +x composer-install.sh npm-install.sh
   ```

2. **Composer/npm not found**

   ```bash
   # For Composer
   curl -sS https://getcomposer.org/installer | php
   sudo mv composer.phar /usr/local/bin/composer
   
   # For npm (install Node.js)
   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

3. **Target directory not found**

   ```bash
   mkdir -p ~/www
   ```

### Debug Mode

To see more detailed output, you can modify the scripts to remove the `--silent` flag from npm or add `--verbose` to composer commands.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the scripts
5. Submit a pull request

## License

[Add your license information here]

## Changelog

### Version 1.1.0

- **NEW**: Automatic git commit for lock files after successful installations
- **NEW**: Automatic removal of problematic `doku/jokul-php-library` dependency
- **IMPROVED**: Enhanced error handling and logging
- **IMPROVED**: Better handling of existing installations (update vs fresh install)

### Version 1.0.0

- Initial release with Composer and npm installers
- Color-coded logging
- Comprehensive error handling
- Summary reporting

---

**Note**: Always test these scripts in a safe environment before running them on production projects.
