
# SourcePackageUpgrader

A robust R package designed to streamline the process of updating and rebuilding installed R packages with enhanced error handling and fallback mechanisms.

## Overview
SourcePackageUpgrader provides automated tools for:
- Updating R packages from source installations
- Identifying and rebuilding packages compiled with different R versions
- Automatic fallback to binary installations when source builds fail
- Detailed reporting of successful and failed package updates
- Version compatibility checking

## Installation
```R
# Install from GitHub
devtools::install_github("replit/SourcePackageUpgrader")

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

## Function Documentation

### updateRpackages()
Main function that handles the complete package update process:
- Checks installed packages
- Updates from source with binary fallback
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

### checkPackageVersion(pkg_name)
Checks if a package needs updating:
- Compares installed and available versions
- Returns version information and update status

## Contributing
Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License
This package is licensed under the MIT License.
