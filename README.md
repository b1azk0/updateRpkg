
# updateRpkg

A robust R package designed to streamline the process of updating and rebuilding installed R packages with enhanced error handling and fallback mechanisms.

## Overview
updateRpkg provides automated tools for:
- Updating R packages from source installations
- Identifying and rebuilding packages compiled with different R versions
- Automatic fallback to binary installations when source builds fail
- Detailed post-run summary reports
- Version compatibility checking
- Package dependency validation
- Self-update checking

## Installation
```R
# Install from GitHub
devtools::install_github("b1azk0/updateRpkg")

# Install directly in R
devtools::install()
```

## Usage
```R
# Load the package
library(updateRpkg)

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
- **Parallel Processing**: Optimized parallel installation support
- **Self-Update Check**: Automatically checks for newer versions of the updater

## Function Documentation

### updateRpackages()
Main function that handles the complete package update process:
- Checks for updates to the updater itself
- Updates installed packages
- Rebuilds outdated packages
- Provides detailed success/failure reporting

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

### checkUpdaterVersion()
Checks if a newer version of updateRpkg is available:
- Compares installed and available versions
- Returns version information and update status

## License
This package is licensed under the MIT License.
