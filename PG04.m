% GDRIVE LINK: https://drive.google.com/file/d/1HpIfeAxv7rKtD3BVuSX3XkrySSJaKbjQ/view?usp=sharing

clear; clc; close all; % initialize MATLAB environment

[take_3,Fs] = audioread("PG04.wav"); % take the array data and Fs
% this is the time vector for final_signal to use for the plot
figure('Name', 'Full Speech Waveform');

t_final = (0:length(take_3)-1) / Fs;
plot(t_final,take_3); % useful for plotting the x coordinate of every vowel
title('Full Audio Recording: Even-Numbered Group Syllables');
xlabel('Time (s)');
ylabel('Amplitude');

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

% extract and subplot the vowel sounds /a/, /o/, and /i/
figure('Name', 'Extracted Vowel Waveforms');

subplot(3,1,1);
t_a = (0:length(a_vowel)-1) / Fs;
plot(t_a, a_vowel);
title('Vowel /a/'); xlabel('Time (s)'); ylabel('Amplitude');

subplot(3,1,2);
t_o = (0:length(o_vowel)-1) / Fs;
plot(t_o, o_vowel);
title('Vowel /o/'); xlabel('Time (s)'); ylabel('Amplitude');

subplot(3,1,3);
t_i = (0:length(i_vowel)-1) / Fs;
plot(t_i, i_vowel);
title('Vowel /i/'); xlabel('Time (s)'); ylabel('Amplitude');

% play in sequence, each of the vowel sounds
% formatting the silence vector as a column vector to prevent concat errors
silence_samples = 1 * Fs; 
pause_vector = zeros(silence_samples, 1); 

all_vowel = [a_vowel; pause_vector; o_vowel; pause_vector; i_vowel]; 
disp('Playing combined vowels /a/, /o/, and /i/ in sequence...');
soundsc(all_vowel, Fs); 

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
