
# SourcePackageUpgrader

A robust R package designed to streamline the process of updating and rebuilding installed R packages with enhanced error handling and fallback mechanisms.

## Overview
SourcePackageUpgrader provides automated tools for:
- Updating R packages from source installations
- Identifying and rebuilding packages compiled with different R versions
- Automatic fallback to binary installations when source builds fail
- Detailed post-run summary reports
- Version compatibility checking
- Package dependency validation

## Installation
```R
# Install from GitHub
devtools::install_github("b1azk0/SourcePackageUpgrader")

# Install directly in R
devtools::install()
```

## Usage
```R
# Load the package
library(SourcePackageUpgrader)

# Update all installed packages
updateRpackages()

# Update specific packages
updatePackages(c("dplyr", "ggplot2"))

# Rebuild outdated packages only
rebuildPackages()
```

## Features
- **Source-First Updates**: Prioritizes source installations for better compatibility
- **Automatic Fallback**: Switches to binary installations if source builds fail
- **Version Compatibility**: Detects packages built with different R versions
- **Progress Tracking**: Reports successful and failed updates
- **Error Handling**: Robust error management with informative messages
- **Version Checking**: Pre-update version comparison to avoid unnecessary updates
- **Detailed Summary Reports**: Comprehensive post-run summaries
- **Package Backup**: Built-in backup and restore functionality

## Function Documentation

### updateRpackages()
Main function that handles the complete package update process:
- Checks installed packages
- Updates from source with binary fallback
- Rebuilds outdated packages
- Provides detailed success/failure reporting
- Generates comprehensive summary report

### updatePackages(packages = NULL)
Updates specific packages or all installed packages:
- Checks current versions before updating
- Attempts source installation first
- Falls back to binary if source fails
- Returns detailed status for each package

### rebuildPackages()
Rebuilds packages compiled with different R versions:
- Identifies outdated builds
- Rebuilds from source with binary fallback
- Returns rebuild status for each package

### checkPackageVersion(pkg_name)
Checks if a package needs updating:
- Compares installed and available versions
- Returns version information and update status

### backupPackages(file_path)
Creates a backup of installed packages:
- Saves package information to CSV
- Stores version and build information

### restorePackages(file_path)
Restores packages from backup:
- Reads backup CSV file
- Reinstalls packages to match backup

## Contributing
Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License
This package is licensed under the MIT License.
