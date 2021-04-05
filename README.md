[![CircleCI](https://circleci.com/gh/pulibrary/vireo_transformation.svg?style=shield)](https://circleci.com/gh/pulibrary/vireo_transformation)

# vireo_transformation
Download theses from Vireo and transform them for Princeton long-term stewardship. It takes `VireoExport`s and turns them into `DspaceImport`s.

## Installation
1. git clone the repository
2. bundle install

## Running the tests
rspec spec

## Processing Vireo Exports
1. Download vireo exports to a directory
2. export VIREO_EXPORT_DIRECTORY=/path/to/your/vireo_exports
3. Make a directory where you want the Data Space import packages written
4. export DSPACE_IMPORT_DIRECTORY=/path/to/your/dspace_imports
