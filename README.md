
# SourcePackageUpgrader

An R package to update and rebuild installed R packages efficiently.

## Features
- Updates all installed R packages from source
- Rebuilds outdated packages
- Automatically retries with binaries if source installation fails
- Provides detailed success/failure reporting

## Usage
```R
# Load the package
library(updateRpkg)

# Run the package updater
updateRpackages()
```
