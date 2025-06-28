# Project Installer Scripts

A collection of automated scripts to install dependencies for PHP (Composer) and Node.js (npm) projects in bulk.

## Overview

This repository contains utility scripts that automatically search for and install dependencies in multiple projects within a specified directory structure. The scripts are designed to work with projects located in `~/www/` directory.

## Scripts

### 1. `install.sh` - Composer Dependencies Installer

Automatically finds all `composer.json` files and runs `composer install` on each project.

### 2. `npm-install.sh` - npm Dependencies Installer  

Automatically finds all `package.json` files and runs `npm install` on each project.

### 3. `composer-install.sh` - Alternative Composer Script

Additional Composer installation script (if different implementation).

## Features

- **🔍 Automatic Discovery**: Recursively searches for dependency files (`composer.json` or `package.json`)
- **🚫 Smart Exclusions**: Skips common directories like `vendor/`, `node_modules/`, `.git/`, etc.
- **✅ Duplicate Prevention**: Checks if dependencies are already installed before running
- **🎨 Colored Output**: Color-coded logging for better readability
- **📊 Summary Report**: Shows successful and failed installations at the end
- **⚡ Error Handling**: Graceful handling of permission issues and failed installations

## Prerequisites

### For Composer Script (`install.sh`)

- **PHP** installed on your system
- **Composer** globally installed and accessible via command line
- Projects with `composer.json` files

### For npm Script (`npm-install.sh`)

- **Node.js** and **npm** installed on your system
- Projects with `package.json` files

## Installation

1. Clone or download the scripts to your desired location:

```bash
git clone <repository-url>
cd _installer
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

```
[INFO] Searching for composer.json files inside /home/user/www...
[INFO] Found composer.json in: /home/user/www/project1
[INFO] Running composer install in: /home/user/www/project1
[SUCCESS] Composer install successful in: /home/user/www/project1
----------------------------------------
[INFO] Found composer.json in: /home/user/www/project2
[WARNING] Vendor directory already exists in /home/user/www/project2. Skipping...
----------------------------------------

[INFO] === SUMMARY ===
[SUCCESS] Successfully installed (1 directories):
  ✓ /home/user/www/project1
[INFO] Done!
```

## Directory Structure

The scripts work with the following directory structure:

```
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
# Change this line in install.sh or npm-install.sh
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
   chmod +x install.sh npm-install.sh
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

### Version 1.0.0

- Initial release with Composer and npm installers
- Color-coded logging
- Comprehensive error handling
- Summary reporting

---

**Note**: Always test these scripts in a safe environment before running them on production projects.
