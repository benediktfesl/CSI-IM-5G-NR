% create default carrier object
carrier = nrCarrierConfig;

% create and configure CSI-IM object, see 3GPP TS 38.214 Section 5.2.2.4. 
csiim = nrCSIIMConfig;
csiim.pattern = 0; % pattern 0 or pattern 1
csiim.SubcarrierLocations = 4;
csiim.SymbolLocations = 9;
csiim.NumCSIRSPorts = 32;
csiim.NumRB = carrier.NSizeGrid;
csiim.RBOffset = carrier.NStartGrid;
csiim.CSIRSPeriod = [5 0];
csiim.Density = 'one';

%% Test different indices functionalities
% linear indexing (1-based)
csiimInd = csiim.indices(carrier); 

% [subcarrier, symbol, antenna] subscript row form indexing (1-based)
csiimInd = csiim.indices(carrier, 'IndexStyle', 'subscript'); 

% {timeInd, SymInd} indexing (1-based)
csiimInd = csiim.indices(carrier, 'IndexStyle', 'separateTimeFreq'); 

% {timeInd, SymInd} indexing (0-based)
csiimInd = csiim.indices(carrier, 'IndexStyle', 'separateTimeFreq', 'IndexBase', '0based'); 

%% Get number of symbols and subcarriers allocated per RB and slot
numSym = csiim.getNumSym();
numCarr = csiim.getNumREsPerRb();

%% Run 5G toolbox simulation over multiple slots

% Create an OFDM resource grid for a slot
dlGrid = nrResourceGrid(carrier,csiim.NumCSIRSPorts);

for nslot=0:15
    fprintf('Slot %d\n',nslot);
    carrier.NSlot = nslot;

    % Set grid to one for visibility
    dlGrid(dlGrid < 1) = 1;

    % Map CSI-IM to the slot resource grid
    csiimInd = csiim.indices(carrier);
    dlGrid(csiimInd) = 0;

    if ~isempty(csiimInd)
        fprintf('CSI-IM configured in slot %d\n',nslot);
    end
end