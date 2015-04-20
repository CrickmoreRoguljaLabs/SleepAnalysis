function [ cycle ] = CircadianFT(activity_5_bin, plot_or_not)
%CircadianFT takes activity data (binned into 5 min) and output the
%circadian length of the genotype.
%   Detailed explanation goes here

% Plot the power spectrum by default
if nargin < 2
    plot_or_not = 1;
end

% Average the activity between flies

activity_5_bin_mean = mean(activity_5_bin , 2);

% Sampling rate once per 5 min
Fs = 1 / (5 * 60);

% Number of FFT points
NFFT = length(activity_5_bin_mean); 

% Frequency vector
F = (0 : 1/NFFT : 1/2-1/NFFT)*Fs; 

% Apply fft
circadian = fft(activity_5_bin_mean,NFFT);

circadian(1 , :) = 0; % remove the DC component for better visualization

% Make power spectrum plot if needed
if plot_or_not > 0
    plot(1./(F * 60 * 60), abs(circadian(1:NFFT/2 , :)));

    xlim([1 24])

    xlabel('hours per activity cycle')

    ylabel('Magnitude')
end


% Find the peak of the power spectrum
[~ , maxind] = max(abs(circadian(1:NFFT/2)));

% Output cycle in terms of hours/cycle. 
cycle = 1 / (F(maxind)* 60 * 60);


end

