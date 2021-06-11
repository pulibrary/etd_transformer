[![CircleCI](https://circleci.com/gh/pulibrary/vireo_transformation.svg?style=shield)](https://circleci.com/gh/pulibrary/vireo_transformation)
[![Coverage Status](https://coveralls.io/repos/github/pulibrary/vireo_transformation/badge.svg?branch=main)](https://coveralls.io/github/pulibrary/vireo_transformation?branch=main)

# vireo_transformation
Download theses from Vireo and transform them for Princeton long-term stewardship. It takes `VireoExport`s and turns them into `DspaceImport`s.

## Version
* Ruby 2.6.5

## Pre-requisites
* ghostscript, for processing PDFs

## Installation
1. git clone the repository
2. bundle install

## Running the tests
rspec spec

## Processing Vireo Exports
We use a thor command line interface. You will need to specify an input directory that contains
Vireo exports for a single department or program, and an empty output directory.
Example:

```
thor etd_transformer:cli:process_theses --input spec/fixtures/mock-downloads/German --output /tmp/2021_theses
```

## Object structure
1. `EtdTransformer` - A top level module to organize things
1. `EtdTransformer::Vireo` - A module for Vireo classes
1. `EtdTransformer::DataSpace` - A module for DataSpace classes
1. `EtdTransformer::Vireo::Submission` - A single thesis, with metadata, as received from Vireo
1. `EtdTransformer::DataSpace::Submission` - A single thesis, with augmented metadata, ready for submission to DataSpace

![](class_diagram.png)
