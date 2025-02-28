classdef nrCSIIMConfig
    %nrCSIIMConfig CSI-IM configuration object
    %   CSIIM = nrCSIIMConfig creates a Channel State Information 
    %   Interference Measurement (CSI-IM) configuration object for single 
    %   CSI-IM resources. This object contains the properties 
    %   related to TS 38.214 Section 5.2.2.4. 
    
    properties
        pattern = 0;
        SymbolLocations = 0;
        SubcarrierLocations = 0;
        Density = 'one';
        NumRB = 52;
        RBOffset = 0;
        NumTxPorts = 1;
        CSIRSPeriod = 'on';
        NID = 0;
    end

    properties (Access = private)
        csirs = nrCSIRSConfig;
    end

    methods
        function csiimInd = indices(obj,carrier,varargin)
            %indices CSI-IM resource element indices
            %   csiimInd = indices(CARRIER) returns the indices of the
            %   Channel State Information Interference Measurement (CSI-IM) resource elements
            %   (REs) as defined in TS 38.214 Section 5.2.2.4, given carrier specific
            %   configuration object CARRIER.

            %   CARRIER is a carrier specific configuration object as described in
            %   <a href="matlab:help('nrCarrierConfig')">nrCarrierConfig</a> with the following properties:
            %
            %   csiimInd = csiimInd(...,NAME,VALUE,...) specifies additional
            %   options as NAME,VALUE pairs to allow control over the format of the
            %   indices:
            %
            %   'IndexStyle'           - 'index' for linear indices (default)
            %                            'subscript' for [subcarrier, symbol, antenna] 
            %                            subscript row form
            %                            'separateTimeFreq' for cell of
            %                            separated {freqIndices, timeIndices}
            %
            %   'IndexBase'            - '1based' for 1-based indices (default) 
            %                            '0based' for 0-based indices

            p = inputParser;
            addRequired(p,'carrier', @(x) isequal(class(x),'nrCarrierConfig'));
            defaultIndex = 'index';
            expectedIndexStyles = {'index','subscript','separateTimeFreq'};
            addOptional(p, 'IndexStyle', defaultIndex, @(x) any(validatestring(x,expectedIndexStyles)));
            defaultBasis = '1based';
            expectedBasis = {'1based','0based'};
            addOptional(p, 'IndexBase', defaultBasis, @(x) any(validatestring(x,expectedBasis)));
            parse(p,carrier,varargin{:});

            [csiimRefInd,~] = nrCSIRSIndices(carrier, obj.csirs,'IndexStyle','subscript');
            if isempty(csiimRefInd)
                csiimInd = csiimRefInd;
                return;
            end

            lenSym = obj.getNumSym();
            symLoc = unique(csiimRefInd(:,2));
            if length(symLoc) ~= lenSym
                error("Wrong indexing.")
            end
            subcarrierLoc = csiimRefInd(1:size(csiimRefInd,1)/obj.csirs.NumCSIRSPorts/length(symLoc)*2,1);
            if strcmp(p.Results.IndexStyle, 'separateTimeFreq')
                if (strcmpi(p.Results.IndexBase,"0based"))
                    subcarrierLoc = subcarrierLoc - 1;
                    symLoc = symLoc - 1;
                end
                csiimInd = {symLoc, subcarrierLoc};
                return;
            end

            csiimInd = repmat(subcarrierLoc,lenSym,1);
            if obj.pattern == 0
                symRep = [symLoc(1)*uint32(ones(size(subcarrierLoc,1),1)); symLoc(2)*uint32(ones(size(subcarrierLoc,1),1))];
            elseif obj.pattern == 1
                symRep = symLoc(1)*uint32(ones(size(subcarrierLoc,1),1));
            end
            csiimInd = [csiimInd, symRep];

            antRep = [];
            for nTx=1:obj.NumTxPorts
                antRep = [antRep;nTx*uint32(ones(size(csiimInd,1),1))];
            end
            csiimInd = repmat(csiimInd,obj.NumTxPorts,1);
            csiimInd = cat(2,csiimInd,antRep);
            if strcmp(p.Results.IndexStyle, 'subscript')
                if (strcmpi(p.Results.IndexBase,"0based"))
                    csiimInd = csiimInd - 1;
                end
                return;
            end
            
            gridsize = [double(carrier.NSizeGrid)*12, carrier.SymbolsPerSlot, obj.NumTxPorts];
            csiimInd = uint32(sub2ind(gridsize,csiimInd(:,1),csiimInd(:,2),csiimInd(:,3)));
            if (strcmpi(p.Results.IndexBase,"0based"))
                csiimInd = csiimInd - 1;
            end
        end

        function numSym = getNumSym(obj)
            numSym = ~obj.pattern + 1;
        end

        function numREsPerRb = getNumREsPerRb(obj)
            numREsPerRb = obj.pattern*2+2;
        end
    
    end

    methods
        function obj = nrCSIIMConfig()
            obj.csirs.CSIRSType = 'zp';
            obj = obj.configureCSIRS();
        end

        function obj = configureCSIRS(obj)
            switch obj.pattern
                case 0  % Similar to CSI-RS pattern 0 (Row 5)
                    obj.csirs.RowNumber = 5;
                case 1  % Similar to CSI-RS pattern 1 (Row 4)
                    obj.csirs.RowNumber = 4;
                otherwise
                    error('Unsupported CSI-IM pattern.');
            end
            obj.csirs.SymbolLocations = obj.SymbolLocations;
            obj.csirs.SubcarrierLocations = obj.SubcarrierLocations;
            obj.csirs.Density = obj.Density;
            obj.csirs.NumRB = obj.NumRB;
            obj.csirs.RBOffset = obj.RBOffset;
            obj.csirs.CSIRSPeriod = obj.CSIRSPeriod;
            obj.csirs.NID = obj.NID;
        end 

        % --- Dynamic Property Set Methods ---
        function obj = set.pattern(obj, value)
            obj.pattern = value;
            switch value
                case 0  % Similar to CSI-RS pattern 0 (Row 5)
                    obj.csirs.RowNumber = 5;
                case 1  % Similar to CSI-RS pattern 1 (Row 4)
                    obj.csirs.RowNumber = 4;
                otherwise
                    error('Unsupported CSI-IM pattern.');
            end
        end

        function obj = set.SymbolLocations(obj, value)
            obj.SymbolLocations = value;
            obj.csirs.SymbolLocations = value; % Auto-update CSIRS object
        end

        function obj = set.SubcarrierLocations(obj, value)
            obj.SubcarrierLocations = value;
            obj.csirs.SubcarrierLocations = value; % Auto-update CSIRS object
        end

        function obj = set.Density(obj, value)
            obj.Density = value;
            obj.csirs.Density = value; % Auto-update CSIRS object
        end

        function obj = set.NumRB(obj, value)
            obj.NumRB = value;
            obj.csirs.NumRB = value; % Auto-update CSIRS object
        end

        function obj = set.RBOffset(obj, value)
            obj.RBOffset = value;
            obj.csirs.RBOffset = value; % Auto-update CSIRS object
        end

        function obj = set.CSIRSPeriod(obj, value)
            obj.CSIRSPeriod = value;
            obj.csirs.CSIRSPeriod = value; % Auto-update CSIRS object
        end

        function obj = set.NID(obj, value)
            obj.NID = value;
            obj.csirs.NID = value; % Auto-update CSIRS object
        end
    end
end

