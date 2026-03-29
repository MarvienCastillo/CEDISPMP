% GDRIVE LINK: https://drive.google.com/file/d/1HpIfeAxv7rKtD3BVuSX3XkrySSJaKbjQ/view?usp=sharing

clear; clc; close all; % initialize MATLAB environment

[take_3,Fs] = audioread("PG04.wav"); % take the array data and Fs

% manually get the x axis value of each vowel using the plot graph of the speech
start_ax = round(0.971875 * Fs); % start x axis of 'a' vowel
end_ax = round(1.16562 * Fs); % end x axis of 'a' vowel

start_ox = round(6.14956 * Fs); % start x axis of 'o' vowel
end_ox = round(6.49806 * Fs); % end x axis of 'o' vowel

start_ix = round(8.3675 * Fs); % start x axis of 'i' vowel
end_ix = round(8.44787 * Fs); % start x axis of 'i' vowel

a_vowel = take_3(start_ax:end_ax); % sliced array for 'a' vowel
o_vowel = take_3(start_ox:end_ox); % sliced array for 'o' vowel
i_vowel = take_3(start_ix:end_ix); % sliced array for 'i' vowel

% calculate and display average pitch for each vowel
disp('--- Average Pitch (Fundamental Frequency) Computations ---');
pitch_a = computePitch(a_vowel, Fs);
fprintf('Average pitch for vowel /a/: %.2f Hz\n', pitch_a);

pitch_o = computePitch(o_vowel, Fs);
fprintf('Average pitch for vowel /o/: %.2f Hz\n', pitch_o);

pitch_i = computePitch(i_vowel, Fs);
fprintf('Average pitch for vowel /i/: %.2f Hz\n', pitch_i);

% function to compute fundamental frequency using autocorrelation
function f0 = computePitch(signal, Fs)
    % remove offset by subtracting mean
    signal = signal - mean(signal);
    
    % autocorrelation
    [r, lags] = xcorr(signal);
    
    % keep only positive lags
    r = r(lags >= 0);
    lags = lags(lags >= 0);
    
    % human pitch range bounds (50 Hz to 500 Hz)
    min_freq = 50; 
    max_freq = 500; 
    
    % convert frequency bounds to lag (samples) bounds
    min_lag = round(Fs / max_freq);
    max_lag = round(Fs / min_freq);
    
    % use 'lags' array to create mask for target range
    valid_mask = (lags >= min_lag) & (lags <= max_lag);
    
    % apply the mask to both r and lags
    valid_r = r(valid_mask);
    valid_lags = lags(valid_mask);
    
    % find the maximum autocorrelation value in this valid range
    [~, max_idx] = max(valid_r);
    
    % extract the true lag from our filtered lags array
    peak_lag = valid_lags(max_idx);
    
    % calculate fundamental frequency
    f0 = Fs / peak_lag;
end

%% Phase 2: Prosody Modification & Synthesis

% Extract syllables manually (Your original extractions)
ma   = take_3(round(0.30*Fs):round(1.23*Fs));
gan  = take_3(round(1.86*Fs):round(2.27*Fs));
dang = take_3(round(2.90*Fs):round(3.30*Fs));
ha   = take_3(round(3.90*Fs):round(4.38*Fs));
pon  = take_3(round(5.01*Fs):round(5.42*Fs));
ga   = take_3(round(7.20*Fs):round(7.57*Fs));
bi   = take_3(round(8.30*Fs):round(8.45*Fs));

% Helper variables for pauses
p = zeros(round(0.1 * Fs), 1); % 0.1s pause between words
P = zeros(round(0.5 * Fs), 1); % 0.5s pause between sentences

% --- Base Word ---
% "Magandang" remains constant across all sentences
magandang = [ma; gan; dang];

%% Sentence 1: /Magandang 'hapon!/ (Greeting - Stress on 'ha', falling pitch on pon)
ha_s1  = 1.2 * change_duration(ha, 1.3); % Louder and longer
pon_s1 = 0.8 * apply_pitch_bend(pon, 'down'); % Quieter, falling tail pitch
s1 = [magandang; p; ha_s1; pon_s1];

%% Sentence 2: /Magandang ha'pon?/ (Question - Stress on 'pon', rising pitch)
ha_s2  = 0.7 * change_duration(ha, 0.3); % Quieter and drastically shorter (fast /a/)
pon_s2 = 1.2 * apply_pitch_bend(change_duration(pon, 1.3), 'up'); % Louder, slightly longer, rising tail pitch
s2 = [magandang; p; ha_s2;pon_s2]; 

%% Sentence 3: /Magandang ga'bi!/ (Greeting - Stress on 'bi', falling pitch)
ga_s3 = 0.8 * ga; % Unstressed, normal duration
bi_s3 = 1.2 * apply_pitch_bend(change_duration(bi, 2), 'up'); % Louder, longer, falling pitch
s3 = [magandang; p; ga_s3; bi_s3];

%% Sentence 4: /Magandang 'gabi, o ga'bi?/ (Alternative Question)
% First part: 'gabi (taro) -> Stress on 'ga
ga_taro = 1.2 * change_duration(ga, 1.5); 
bi_taro = 0.8 * bi; 
word_taro = [ga_taro; bi_taro];

% Second part: ga'bi? (evening) -> Stress on 'bi, rising pitch
ga_eve = 0.8 * ga;
bi_eve = 1.2 * apply_pitch_bend(change_duration(bi, 2), 'up');
word_eve = [ga_eve; bi_eve];

% Combine sentence 4
s4 = [magandang; p; word_taro; P; o_vowel; p; word_eve];


%% Output, Plotting, and Saving
sentences = {s1, s2, s3, s4};
titles = {'/Magandang hapon!/', '/Magandang ha''pon?/', '/Magandang gabi!/', '/Magandang ''gabi, o ga''bi?/'};
group_num = 'PG04'; 

figure('Name', 'Synthesized Sentences');
for i = 1:4
    % Plotting
    subplot(4,1,i);
    % Calculate custom time vector for each synthesized sentence
    t_synth = (0:length(sentences{i})-1)/Fs;
    plot(t_synth, sentences{i});
    title(titles{i});
    xlabel('Time (s)'); ylabel('Amp');
    
    % Saving WAV files
    filename = sprintf('sentence_%d_%s.wav', i, group_num);
    audiowrite(filename, sentences{i}, Fs);
    
    % Playback
    fprintf('Playing Sentence %d...\n', i);
    soundsc(sentences{i}, Fs);
    pause(length(sentences{i})/Fs + 0.5); % Wait for audio to finish before next loop
end

% =========================================================================
% LOCAL FUNCTIONS FOR PROSODY MODIFICATION (Place at the very bottom!)
% =========================================================================

function out = change_duration(syl, factor)
    % Changes duration but adds a tiny fade to edges to prevent clicking
    Fs_local = 16000; 
    fade_len = round(0.000005 * Fs_local);
    
    % Standard duration logic
    len = length(syl);
    third = round(len/3);
    head = syl(1:third);
    middle = syl(third+1:2*third);
    tail = syl(2*third+1:end);
    
    if factor >= 1
        % Repeat the middle segment (e.g., factor=2 doubles the middle length)
        middle_mod = repmat(middle, round(factor), 1);
    else
        % Shrink the middle segment (e.g., factor=0.3 keeps only 30% of the middle)
        keep_len = round(length(middle) * factor);
        middle_mod = middle(1:keep_len);
    end
    
    combined = [head; middle_mod; tail];
    
    % Apply Fades
    win_in = linspace(0, 1, fade_len)'; % generates an array 0 to 1 
    win_out = linspace(1, 0, fade_len)'; % generates an array 1 to 0
    combined(1:fade_len) = combined(1:fade_len) .* win_in; % uses win_in to increase the volume of the first sample to nth sample 
    combined(end-fade_len+1:end) = combined(end-fade_len+1:end) .* win_out; % uses win_out to lower the volume from after the nth sample to end
    out = combined;
end

function out = apply_pitch_bend(syl, direction)
    % Creates a smoother pitch glide instead of a sudden jump
    len = length(syl);
    idx = round(len * 0.7); 
    head = syl(1:idx-1);
    tail = syl(idx:end);
    
    % Break tail into two halves for a multi-stage glide
    mid_point = round(length(tail)/2);
    t1 = tail(1:mid_point);
    t2 = tail(mid_point+1:end);
    
    if strcmp(direction, 'up')
        % Gradual rise
        t1 = resample(t1, 11, 12); % slight rise
        t2 = resample(t2, 9, 11);  % sharper rise
    elseif strcmp(direction, 'down')
        % Gradual fall
        t1 = resample(t1, 12, 11); % slight fall
        t2 = resample(t2, 11, 9);  % sharper fall
    end
    out = [head; t1; t2];
end
