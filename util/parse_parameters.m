function [split, descriptorType, encode, normalize, gmmSize, dataset] = parse_parameters(varargin)
    p = inputParser;
    defaultNorm = 'Power-L2';
    defaultSplit = 1;
    defaultEncode = 'fv';
    defaultDescriptor = {'hog','hof','mbhx','mbhy'};
    defaultData = 'jhmdb';
    
    addParamValue(p,'split',defaultSplit,@isnumeric)
    addParamValue(p,'gmmSize',256,@isnumeric)
    addParamValue(p,'descriptor',defaultDescriptor,@iscell)
    addParamValue(p,'encode',defaultEncode,@ischar)
    addParamValue(p,'normalize',defaultNorm,@ischar)
    addParamValue(p,'dataset',defaultData,@ischar)
    parse(p, varargin{:})
    descriptorType = p.Results.descriptor;
    encode = p.Results.encode;
    normalize = p.Results.normalize;
    split = p.Results.split;
    gmmSize = p.Results.gmmSize;
    dataset = p.Results.dataset;
end