# nrCSIIMConfig

`nrCSIIMConfig` is a MATLAB class for configuring Channel State Information Interference Measurement (CSI-IM) resources in compliance with 3GPP TS 38.214 Section 5.2.2.4. It leverages the `nrCSIRSConfig` object from the 5G Toolbox to handle Channel State Information Reference Signal (CSI-RS)-related configuration internally while exposing a simplified interface for CSI-IM setup.

## Motivation

3GPP NR distinguishes CSI-IM resources from CSI-RS resources. MATLAB 5G Toolbox provides CSI-RS and zero-power CSI-RS configuration through `nrCSIRSConfig`, but it does not expose a dedicated CSI-IM configuration object.

This repository provides a lightweight `nrCSIIMConfig` class for MATLAB-based 5G NR simulations where CSI-IM resources should be represented explicitly instead of being treated as ordinary ZP CSI-RS resources.

A concrete limitation of using CSI-RS objects directly as a CSI-IM substitute is that CSI-RS resource mapping is tied to the CSI-RS row number in 3GPP TS 38.211 Table 7.4.1.5.3-1. In MATLAB 5G Toolbox, `nrCSIRSConfig.RowNumber` determines several CSI-RS-specific properties, including the number of CSI-RS antenna ports and the CDM type. This is appropriate for CSI-RS, but it is not the correct abstraction for CSI-IM: CSI-IM defines interference-measurement resource patterns in TS 38.214 Section 5.2.2.4 and is not configured as a transmitted reference signal with an associated number of CSI-RS antenna ports.

For this reason, the class exposes CSI-IM pattern selection explicitly and only uses CSI-RS rows internally to reproduce the corresponding resource-element geometry:

- CSI-IM pattern 0 uses CSI-RS row 5 internally.
- CSI-IM pattern 1 uses CSI-RS row 4 internally.

This row mapping is an implementation helper for generating the expected resource-element locations. It should not be interpreted as a conceptual equivalence between CSI-IM and ZP CSI-RS.


## Features

- Supports CSI-IM patterns 0 and 1, corresponding to the resource structures used for CSI interference measurement.
- Maps CSI-IM pattern 0 to CSI-RS row 5 internally.
- Maps CSI-IM pattern 1 to CSI-RS row 4 internally.
- Provides configurable symbol locations, subcarrier locations, resource block allocation, density, and periodicity.
- Supports an arbitrary number of transmit ports for CSI-IM configuration workflows without exposing CSI-RS row-number selection as the primary user interface.
- Automatically configures the internally used `nrCSIRSConfig` helper object.
- Generates CSI-IM resource element indices from a configured `nrCarrierConfig` object.
- Supports multiple index output formats:
  - linear indices
  - subscript indices
  - separated time/frequency indices
- Supports both 1-based and 0-based index output.

## Requirements

- MATLAB
- 5G Toolbox

## Installation

Clone the repository or download it from MATLAB File Exchange, then add the repository folder to your MATLAB path:

```matlab
addpath("path/to/CSI-IM-5G-NR")
```

## Basic Usage

```matlab
% Create default carrier object
carrier = nrCarrierConfig;

% Create CSI-IM configuration object
csiim = nrCSIIMConfig;

% Configure CSI-IM resource
csiim.Pattern = 0;              % CSI-IM pattern 0 or 1
csiim.SubcarrierLocations = 4;
csiim.SymbolLocations = 9;
csiim.NumTxPorts = 32;
csiim.NumRB = carrier.NSizeGrid;
csiim.RBOffset = carrier.NStartGrid;
csiim.CSIRSPeriod = [5 0];
csiim.Density = 'one';

% Get CSI-IM resource element indices in linear 1-based format
csiimInd = csiim.indices(carrier);
```

## CSI-IM Pattern

The public pattern selection follows the CSI-IM terminology:

```matlab
csiim.Pattern = 0;  % CSI-IM pattern 0
csiim.Pattern = 1;  % CSI-IM pattern 1
```

## Index Output Formats

### Linear indices

```matlab
csiimInd = csiim.indices(carrier);
```

### Subscript indices

```matlab
csiimSub = csiim.indices(carrier, 'IndexStyle', 'subscript');
```

### Zero-based indices

```matlab
csiimInd0 = csiim.indices(carrier, 'IndexBase', '0based');
```

### Separated time/frequency indices

```matlab
csiimTF = csiim.indices(carrier, 'IndexStyle', 'separateTimeFreq');
```


## Example

The repository includes `example.m`, which demonstrates basic configuration and index generation.

Run it from MATLAB after adding the repository folder to the MATLAB path:

```matlab
example
```

## Repository Structure

```text
CSI-IM-5G-NR/
├── README.md
├── LICENSE.txt
├── nrCSIIMConfig.m
└── example.m
```

## Notes

This is an independent research utility and is not an official MathWorks implementation. It is intended to make CSI-IM resources explicit in MATLAB-based 5G NR simulation workflows.

## Citation

If you use this repository in academic work, please cite the repository or the corresponding GitHub/File Exchange release.

## Contact

For questions, issues, or contributions, please open an issue or submit a pull request on GitHub.
