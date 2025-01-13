
# SourcePackageUpgrader

A robust R package designed to streamline the process of updating and rebuilding installed R packages with enhanced error handling and fallback mechanisms.

## Overview
SourcePackageUpgrader provides automated tools for:
- Updating R packages from source installations
- Identifying and rebuilding packages compiled with different R versions
- Automatic fallback to binary installations when source builds fail
- Detailed reporting of successful and failed package updates

## Installation
```R
# Install directly in R
devtools::install()
```

## Usage
```R
# Load the package
library(updateRpkg)

# Update all installed packages
updateRpackages()
```

## Features
- **Source-First Updates**: Prioritizes source installations for better compatibility
- **Automatic Fallback**: Switches to binary installations if source builds fail
- **Version Compatibility**: Detects packages built with different R versions
- **Progress Tracking**: Reports successful and failed updates
- **Error Handling**: Robust error management with informative messages

## Function Documentation
### updateRpackages()
Main function that handles the package update process:
- Checks installed packages
- Updates from source
- Rebuilds outdated packages
- Provides detailed success/failure reporting

## Contributing
Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License
This package is licensed under the MIT License.
