%% Synthesized Multi‑Channel Strobe Loader for SCCS
% This script:
%   1. Loads a CSV file (with 4 candidate frequency and amplitude columns).
%   2. Lets the user choose an interval transposition (or unison) – the chosen
%      transposition determines which frequency columns to use.
%   3. Asks if the duty cycle should be inverted.
%   4. Asks for channel mapping mode:
%         (1) Use 1 column for all 4 outputs,
%         (2) Use 2 columns (col1 for LEDs 1-2; col2 for LEDs 3-4),
%         (4) Use all 4 columns individually.
%   5. Interpolates the candidate channels over the session.
%   6. Every altPeriod seconds, randomly reassigns the candidate channels to the
%      four ring LED channels.
%   7. Generates a square–wave LED pattern based on the (interpolated) frequency
%      and dynamic duty cycle (computed from Amplitude_SCCS).
%   8. Sets the center LED off and assigns ring brightness as DAC data.
%   9. Converts the LED pattern to an 8–bit value per frame and packages it as a
%      1D array.
%  10. Loads the data to the device.
%  11. Produces two plots: an overlay and a 2×2 subplot view.

clear; clc;

addpath('C:\Users\dn284\Desktop\strobe\octAVEs')

%% ========== USER INPUT & FILE LOADING ==========
% Set the path to your CSV file (produced by the omni script)
csvFilePath = "C:\Users\dn284\Desktop\strobe\octAVEs\data\rainy.csv";
data = readtable(csvFilePath);

% Ask for the session name.
session_name = input('Enter the song/session name: ', 's');

% Ask for transposition direction and interval.
direction_choice = input('Choose interval direction: (0) Unison, (1) Up, (2) Down: ');
intervalList = {'Unison','Minor Second','Major Second','Minor Third','Major Third',...
    'Perfect Fourth','Tritone','Perfect Fifth','Minor Sixth','Major Sixth',...
    'Minor Seventh','Major Seventh','Octave'};
for i = 1:length(intervalList)
    fprintf('(%d) %s\n', i-1, intervalList{i});
end
interval_choice = input('Choose interval (0-12): ');

nChannels = 4;  % Expecting 4 candidate channels in the CSV.
freqColNames = strings(1,nChannels);
brightColNames = strings(1,nChannels);

if interval_choice == 0
    % Unison: use the base frequency columns.
    for ch = 1:nChannels
        freqColNames(ch) = sprintf("Adjusted_Corr_Freq_%d", ch);
        brightColNames(ch) = sprintf("Amplitude_SCCS_%d", ch);
    end
    fprintf('Using Unison (base corresponding frequencies) for all channels.\n');
    intervalName = "Unison";
    dirStr = "";
else
    if direction_choice == 1
        dirStr = "Up";
    elseif direction_choice == 2
        dirStr = "Down";
    else
        error('Invalid direction choice! Choose 0, 1, or 2.');
    end
    intervalName = erase(intervalList{interval_choice+1}, ' ');
    for ch = 1:nChannels
        % Example: "MajorThird_Down_Freq_1"
        freqColNames(ch) = sprintf("%s_%s_Freq_%d", intervalName, dirStr, ch);
        brightColNames(ch) = sprintf("Amplitude_SCCS_%d", ch);
    end
    fprintf('Using %s %s for channels (columns: %s).\n', intervalName, dirStr, join(freqColNames, ', '));
end

% Ask if duty cycle should be inverted.
invert_choice = input('Invert duty cycle? (y/n): ', 's');
invert_duty = strcmpi(invert_choice, 'y');

% Ask for channel mapping mode.
mapping_mode = input('Enter channel mapping mode: (1) 1 channel to all 4, (2) 2 channels, (4) Use all 4 channels: ');
if ~ismember(mapping_mode, [1,2,4])
    error('Invalid mapping mode. Choose 1, 2, or 4.');
end

% Get the time vector and calculate song length.
timeCSV = data.Time;
song_length = max(timeCSV) - min(timeCSV);
fprintf('Song length: %.2f seconds.\n', song_length);

%% ========== INTERPOLATION ==========
frameRate = 2000;  % Hz
frameDurationS = 1/frameRate;
sampleTimes = (0:frameDurationS:(song_length - frameDurationS))';

nFrames = length(sampleTimes);
stimulationFreqs = zeros(nFrames, nChannels);
brightnessVals = zeros(nFrames, nChannels);

interpFreqMethod = 'nearest';
interpBrightMethod = 'linear';

for ch = 1:nChannels
    stimFreq = interp1(timeCSV, data.(freqColNames(ch)), sampleTimes, interpFreqMethod);
    stimulationFreqs(:, ch) = stimFreq;
    bright = interp1(timeCSV, data.(brightColNames(ch)), sampleTimes, interpBrightMethod);
    brightnessVals(:, ch) = round(bright);
end

%% ========== CHANNEL MAPPING DUPLICATION ==========
% Duplicate channel data based on mapping mode.
switch mapping_mode
    case 1  % Use column 1 for all 4 outputs.
        stimulationFreqs(:,2:4) = repmat(stimulationFreqs(:,1), 1, 3);
        brightnessVals(:,2:4) = repmat(brightnessVals(:,1), 1, 3);
    case 2  % Use 2 channels: channel 1 for outputs 1-2; channel 2 for outputs 3-4.
        stimulationFreqs(:,3:4) = repmat(stimulationFreqs(:,2), 1, 2);
        brightnessVals(:,3:4) = repmat(brightnessVals(:,2), 1, 2);
    case 4
        % Use all 4 channels as is.
    otherwise
        error('Unexpected mapping mode.');
end

%% ========== ROTATING ASSIGNMENT OF CHANNELS ==========
altPeriod = 1;  % seconds
altStep = round(altPeriod * frameRate);
nAltBlocks = ceil(nFrames / altStep);

ringFreqs = zeros(nFrames, nChannels);
ringBrightness = zeros(nFrames, nChannels);

for block = 1:nAltBlocks
    idx_start = (block-1)*altStep + 1;
    idx_end = min(block*altStep, nFrames);
    blockIdx = idx_start:idx_end;
    perm = randperm(nChannels);  % Random permutation
    for ledCh = 1:nChannels
        candidate = perm(ledCh);
        ringFreqs(blockIdx, ledCh) = stimulationFreqs(blockIdx, candidate);
        ringBrightness(blockIdx, ledCh) = brightnessVals(blockIdx, candidate);
    end
end

%% ========== LED PATTERN GENERATION ==========
% Generate LED "on" pattern based on ring frequency and duty cycle.
ledONPattern = zeros(nFrames, 8);
waveformType = 'square';

for ch = 1:nChannels
    dutyCycle = (ringBrightness(:, ch) / 255) * 100;  % Convert amplitude (0-255) to duty cycle (%)
    phase = mod(sampleTimes .* ringFreqs(:, ch), 1);
    ledONPattern(:, ch) = phase < (dutyCycle / 100);
    ledONPattern(:, ch+4) = ledONPattern(:, ch);  % Mirror for additional channels
end

%% ========== DAC BRIGHTNESS (CENTER OFF) ==========
centralBrightness = zeros(nFrames, 1);   % Center LED off.
dacChannelValuesPerSample = [centralBrightness, ringBrightness];

%% ========== FINAL DATA PACKAGING ==========
ledONBitmap = binary8ToUint8(ledONPattern);
preparedStrobeData2D = [ledONBitmap, dacChannelValuesPerSample];
preparedStrobeData1D = reshape(preparedStrobeData2D', [], 1)';

%% ===== PREPARE VARIABLES FOR PLOTTING =====
% Determine the transposition label for plotting.
if interval_choice == 0
    clean_column_name = 'Unison';
else
    clean_column_name = sprintf('%s %s', intervalName, dirStr);
end

% For plotting, we use the selected frequency columns.
% (This script uses the interpolation data stored in 'stimulationFreqs'.)
interpolatedCorrFreqs = mean(stimulationFreqs, 2);

differenceTones = zeros(size(stimulationFreqs));
summationTones  = zeros(size(stimulationFreqs));
for ch = 1:nChannels
    differenceTones(:, ch) = abs(stimulationFreqs(:, ch) - interpolatedCorrFreqs);
    summationTones(:, ch)  = stimulationFreqs(:, ch) + interpolatedCorrFreqs;
end

dutyCycleVals = (brightnessVals ./ 255) * 100;

%% ===== PLOTTING: Overlay Plot =====
% Determine number of channels to plot based on mapping_mode.
nPlotChannels = mapping_mode;  % mapping_mode is 1, 2, or 4
colors = lines(nPlotChannels);

figure(1);  % Explicitly assign overlay plot to figure 1
clf;        % Clear the figure
hold on;

% --- Left Y-axis: Frequency-related plots ---
yyaxis left;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
xlim([0, song_length]);

% Compute maximum frequency for y-limits over the selected channels.
maxY_val = max([ max(stimulationFreqs(:,1:nPlotChannels),[],'all'), ...
                 max(differenceTones(:,1:nPlotChannels),[],'all'), ...
                 max(summationTones(:,1:nPlotChannels),[],'all'), ...
                 max(interpolatedCorrFreqs) ]);
ylim([0, maxY_val]);

for ch = 1:nPlotChannels
    plot(sampleTimes, stimulationFreqs(:, ch), 'Color', colors(ch,:), 'LineWidth', 1.5, ...
         'DisplayName', sprintf('Ch%d: %s', ch, clean_column_name));
    plot(sampleTimes, differenceTones(:, ch), '--', 'Color', colors(ch,:), 'LineWidth', 1.2, ...
         'DisplayName', sprintf('Ch%d Diff Tone', ch));
    plot(sampleTimes, summationTones(:, ch), ':', 'Color', colors(ch,:), 'LineWidth', 1.2, ...
         'DisplayName', sprintf('Ch%d Sum Tone', ch));
end

% Plot the Music Frequency (averaged) in black.
plot(sampleTimes, interpolatedCorrFreqs, 'k--', 'LineWidth', 2, 'DisplayName', 'Music Frequency');

% --- Right Y-axis: Duty Cycle and/or Brightness ---
yyaxis right;
if ~invert_duty
    ylabel('Duty Cycle & Brightness (%)');
    for ch = 1:nPlotChannels
        % When not inverted, the duty cycle and brightness are identical.
        plot(sampleTimes, dutyCycleVals(:, ch), 'LineWidth', 1.5, 'Color', [colors(ch,:) 0.9], ...
             'DisplayName', sprintf('Ch%d: Duty Cycle & Brightness', ch));
    end
else
    ylabel('Percent (%)');
    for ch = 1:nPlotChannels
        % Plot the original duty cycle.
        plot(sampleTimes, dutyCycleVals(:, ch), 'LineWidth', 1.5, 'Color', [colors(ch,:) 0.9], ...
             'DisplayName', sprintf('Ch%d Duty Cycle', ch));
        % Compute a slightly hue-shifted color for brightness.
        hsvColor = rgb2hsv(colors(ch,:));
        hsvColor(1) = mod(hsvColor(1) + 0.07, 1); % slight hue shift
        brightnessColor = hsv2rgb(hsvColor);
        % Plot brightness (inverted duty cycle).
        plot(sampleTimes, 100 - dutyCycleVals(:, ch), 'LineWidth', 1.5, 'Color', [brightnessColor 0.9], ...
             'DisplayName', sprintf('Ch%d Brightness', ch));
    end
end

legend('Location', 'best');

% Here we create a two-line title so that an empty line adds spacing.
title({sprintf('%s | Selected Audiovisual Transposition: %s | Channels: %d', ...
    session_name, clean_column_name, nPlotChannels), ' '});

hold off;
drawnow;  % Force update of figure 1

%% ===== PLOTTING: Subplots (One per Selected Channel) =====
nPlotChannels = mapping_mode;  % Use the chosen number of channels
colors = lines(nPlotChannels);

figure(2);  % Create a new figure for subplots
clf;

% Choose an appropriate subplot layout.
if nPlotChannels == 1
    tiledlayout(1,1);
elseif nPlotChannels == 2
    tiledlayout(1,2);
elseif nPlotChannels == 4
    tiledlayout(2,2);
else
    nRows = ceil(sqrt(nPlotChannels));
    nCols = ceil(nPlotChannels / nRows);
    tiledlayout(nRows, nCols);
end

for ch = 1:nPlotChannels
    baseColor = colors(ch,:);
    % Prepare a hue-shifted variant for the right-axis plot.
    hsvBase = rgb2hsv(baseColor);
    hsvBase(1) = mod(hsvBase(1) + 0.07, 1);
    shiftedColor = hsv2rgb(hsvBase);
    
    nexttile;
    hold on;
    
    %% --- Left Y-axis: Frequency ---
    yyaxis left;
    plot(sampleTimes, stimulationFreqs(:, ch), 'Color', baseColor, 'LineWidth', 1.5, ...
         'DisplayName', sprintf('Ch%d: %s', ch, clean_column_name));
    plot(sampleTimes, differenceTones(:, ch), '--', 'Color', [baseColor, 0.2], 'LineWidth', 1, ...
         'DisplayName', sprintf('Ch%d Diff Tone', ch));
    plot(sampleTimes, summationTones(:, ch), ':', 'Color', [baseColor, 0.2], 'LineWidth', 1, ...
         'DisplayName', sprintf('Ch%d Sum Tone', ch));
    plot(sampleTimes, interpolatedCorrFreqs, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Music Frequency');
    
    ylabel('Frequency (Hz)');
    maxY_ch = max([ max(stimulationFreqs(:, ch)), max(differenceTones(:, ch)), ...
                    max(summationTones(:, ch)), max(interpolatedCorrFreqs) ]);
    ylim([0, maxY_ch]);
    
    %% --- Right Y-axis: Duty Cycle and/or Brightness ---
    yyaxis right;
    if ~invert_duty
        ylabel('Duty Cycle & Brightness (%)');
        plot(sampleTimes, dutyCycleVals(:, ch), 'Color', [baseColor, 0.9], 'LineWidth', 1.5, ...
             'DisplayName', sprintf('Ch%d: Duty Cycle & Brightness', ch));
    else
        ylabel('Percent (%)');
        plot(sampleTimes, dutyCycleVals(:, ch), 'Color', [baseColor, 0.9], 'LineWidth', 1.5, ...
             'DisplayName', sprintf('Ch%d Duty Cycle', ch));
        plot(sampleTimes, 100 - dutyCycleVals(:, ch), 'Color', [shiftedColor, 0.9], 'LineWidth', 1.5, ...
             'DisplayName', sprintf('Ch%d Brightness', ch));
    end
    ylim([0, 100]);
    xlabel('Time (s)');
    title(sprintf('Channel %d', ch));
    legend('Location', 'best');
    hold off;
end

sgtitle(sprintf('%s | Selected Audiovisual Transposition: %s | Channels: %d', ...
    session_name, clean_column_name, nPlotChannels));

%% ===== LOAD DATA TO DEVICE =====
comPort = 'COM3';  % Replace with your actual COM port.
filename = [session_name, '.txt'];
success = SCCS_strobe_load_device(preparedStrobeData1D, comPort, filename);
if success
    disp('Strobe data successfully loaded and played on the device.');
else
    error('Failed to load strobe data to the device.');
end

%% ===== HELPER FUNCTION =====
function value = binary8ToUint8(bitArray)
    weights = [128, 64, 32, 16, 8, 4, 2, 1];
    value = uint8(sum(double(bitArray) .* weights, 2));
end