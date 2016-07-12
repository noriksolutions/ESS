classdef TrialAverage < Block
    properties
        numberOfTrials
    end;
    
    methods
        function obj = TrialAverage(varargin)
            obj = obj@Block;
            obj = obj.defineAsSubType('TrialAverage');
            obj = obj.setId;
            
            if nargin > 0
                if isa(varargin{1}, 'Block')
                    trialBlock = varargin{1};
                    obj.axes{1} = FeatureAxis('names', {'mean', 'standard deviation of mean', 'median', 'median absolute deviation'});
                    nonTrialAxisLabels = {};
                    axesLengths = length(obj.axes{1});
                    for i=1:length(trialBlock.axes)
                        if strcmp(trialBlock.axes{i}.typeLabel, 'trial')
                            numberOfTrials = length(trialBlock.axes{i});
                        else
                            nonTrialAxisLabels{end+1} = trialBlock.axes{i}.typeLabel;
                            obj.axes{end+1} = trialBlock.axes{i};
                            axesLengths(end+1) = length(trialBlock.axes{i});
                        end;
                    end
                    
                    obj.tensor = zeros(axesLengths);
                    
                    obj.tensor(1,:) = vec(mean(trialBlock.index('trial', nonTrialAxisLabels{:})));
                    obj.tensor(2,:) = vec(std(trialBlock.index('trial', nonTrialAxisLabels{:})) / sqrt(length(trialBlock.trial)));
                    m = median(trialBlock.index('trial', nonTrialAxisLabels{:}));
                    obj.tensor(3,:) = vec(m);
                    obj.tensor(4,:) = vec(median(abs(bsxfun(@minus, trialBlock.index('trial', nonTrialAxisLabels{:}), m))));
                end;
            end;
        end
        
        function obj = plot(obj, varargin)
            %             inputOptions = arg_define(varargin, ...
            %                 arg('channelIndices',[],[],'EEG channel indices to use. If empty and no "channellabels" is provided then all channels will be selected. If both "channelIndices" and "channellabels" are provided, their intersection will be used.'), ...
            %                 arg('channellabels',[],[],'EEG channel labels to use. If both "channelIndices" and "channellabels" are provided, their intersection will be used.'), ...
            %                 arg('timeRange',[-2 2],[],'Time range [before after] to include in the epoch. This is in seconds.'), ...
            %                 arg('lowpass', 0.5,[0 Inf],'Low-pass EEG at this frequency. Use empty to skip'), ...
            %                 arg('highpass', 20,[0 Inf],'High-pass EEG at this frequency. Leave empty to skip.'), ...
            %                 arg('maxChannels', Inf,[1 Inf],'Maximum number of channels to use. A uniform subset of channels will be used if this value is less than the number of channels in EEG.'), ...
            %                 arg_sub('select',{},@EpochedFeature.getTrialTimesFromEEGstructure, 'A struct argument. Arguments are as in myotherfunction(), can be assigned as a cell array of name-value pairs or structs.'));
            %
            
            if length(obj.axes) == 3
                time = obj.getAxis('time');
                plot(time.times, squeeze(obj.index({'feature' 'name' 'mean'}, {'channel', 1}, 'time')));
            end;
        end;
    end
end