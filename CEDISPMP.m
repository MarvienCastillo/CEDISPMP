[take_3,Fs] = audioread("Take1.wav"); % take the array data and Fs
plot(t_final,take_3); % useful for plotting the x coordinate of every vowel
silence_samples = 1 * Fs; % silence
pause_vector = zeros(1, silence_samples); % pause vector
start_ax = round(1.51792 * Fs); % start x axis of 'a' vowel
end_ax = round(1.7724 * Fs); % end x axis of 'a' vowel

start_ox = round(6.5824 * Fs); % start x axis of 'o' vowel
end_ox = round(6.85265 * Fs); % end x axis of 'o' vowel

start_ix = round(8.69154 * Fs); % start x axis of 'i' vowel
end_ix = round(8.8129 * Fs); % start x axis of 'i' vowel

a_vowel = take_3(start_ax:end_ax); % sliced array for 'a' vowel
o_vowel = take_3(start_ox:end_ox); % sliced array for 'o' vowel
i_vowel = take_3(start_ix:end_ix); % sliced array for 'i' vowel
all_vowel = [a_vowel; pause_vector'; o_vowel; pause_vector'; i_vowel]; % combined sliced array of vowels and added pause_vector
soundsc(all_vowel,Fs); % testing sound