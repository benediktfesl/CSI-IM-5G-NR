# nrCSIIMConfig

## Overview
`nrCSIIMConfig` is a MATLAB class for configuring Channel State Information Interference Measurement (CSI-IM) in compliance with 3GPP TS 38.214 Section 5.2.2.4. It leverages the `nrCSIRSConfig` object from the 5G Toolbox to handle CSI-RS-related configurations internally while exposing a simplified interface for CSI-IM setup.

## Features
- Supports CSI-IM patterns 0 and 1 similar to CSI-RS rows 5 and 4, respectively.
- Configurable with any number of Tx ports in contrast to CSI-RS configuration with row 4 and 5.
- Automatically configures the internally used `nrCSIRSConfig` object.
- Enables setting all CSI-IM parameters such as symbol locations, subcarrier locations, and resource block allocation.
- Get CSI-IM resource element indices from pre-configured carrier object with different formatting options.

## Installation
Ensure you have the MATLAB 5G Toolbox installed before using this package.

## Usage

Below is an example script demonstrating how to use `nrCSIIMConfig`:

```matlab
% Create a CSI-IM configuration object with default settings
csiim = nrCSIIMConfig;

% Modify properties
csiim = nrCSIIMConfig;
csiim.pattern = 0; % pattern 0 or pattern 1
csiim.SubcarrierLocations = 4;
csiim.SymbolLocations = 9;
csiim.NumCSIRSPorts = 32; 
csiim.NumRB = carrier.NSizeGrid;
csiim.RBOffset = carrier.NStartGrid;
csiim.CSIRSPeriod = [5 0];
csiim.Density = 'one';

% create default carrier object
carrier = nrCarrierConfig;

% Get resource element indices in linear indexing format
csiImInd = csiim.indices(carrier); 
```

## Repository Structure
```
repo/
│   README.md    % Documentation
│   nrCSIIMConfig.m  % CSI-IM Configuration Class
│   example.m    % Example usage script
```

## Contact
For questions or contributions, feel free to open an issue or submit a pull request.



