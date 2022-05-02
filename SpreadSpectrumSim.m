%% Spread Spectrum Simulator
% Nolan Pearce
% 02 May 2022
% This project simulates a standard "APRS" packet at a specified bit rate
% against gaussian power distribution, spread spctrum, and using various
% encoding schemes to illustrate benefits of transmission.

%% Inputs
% Encoding scheme (only changes packet length to 20 bytes or 13 bytes)
% Modulation is AFSK 9600 baud
% Packets have same length
% Spread spectrum or standard

% Generate the random byte

s = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
%find number of random characters to choose from
numRands = length(s); 
%specify length of random string to generate
sLength20 = 20;
sLength13 = 13;
%generate random string
randString = s( ceil(rand(1,sLength20)*numRands) );
randString91 = s( ceil(rand(1,sLength13)*numRands) );
asciiString = double(randString);
asciiString91 = double(randString91);

binvec = reshape(dec2bin(asciiString),[],1); %reshape(A,[],1) 
binvec91 = reshape(dec2bin(asciiString91),[],1);

% Modulate signal, from https://www.notblackmagic.com/bitsnpieces/afsk/
%samplingFreq = 1e3;
%bitrate = 9600;
fMark = 1200;
fSpace = 2200;
%index = 1;

bitstream = binvec;
period = 0:1/fSpace:(1200/1200);
period2 = 0:1/fMark:(2200/1200);
spaceWave = sin(2.*pi.*period);
markWave = sin(2.*pi.*period2);
y = zeros(length(bitstream),length(spaceWave));
for m=1:length(bitstream)
    if strcmp(bitstream(m),'1') == 1
    y(m,:) = markWave;
    else
    y(m,:) = spaceWave;
    end
end
wave = zeros(1,(length(bitstream)*2201));
for k=1:140
    for m=1:2201
        wave(1,(2201*(k-1) + m)) = y(k,m);
    end
end

clear bitstream
clear y

bitstream = binvec91;
y = zeros(length(bitstream),length(spaceWave));
for m=1:length(bitstream)
    if strcmp(bitstream(m),'1') == 1
    y(m,:) = markWave;
    else
    y(m,:) = spaceWave;
    end
end
wave91 = zeros(1,(length(bitstream)*2201));
for k=1:length(bitstream)
    for m=1:2201
        wave91(1,(2201*(k-1) + m)) = y(k,m);
    end
end

figure(1)
hold on
plot(wave(1.5e5 : 2e5), ":", "LineWidth", 2)
title("Overlaid Baseband Standard and Base91 Signal")
plot(wave91(1.5e5 : 2e5), "LineWidth", 1 )
legend("Standard", "Base91")
hold off

EbNoVec = (20:25)';
berEst = zeros(size(EbNoVec));

    % Reset the error and bit counters
    numErrs = 0;
    numBits = 0;

    dataSym = wave;
    dataIn = wave; %use int values
        
    % QAM modulate using 'Gray' symbol mapping
    Fc = 20e3;
    Fs = 2*Fc;
    freqdev = 5e3;
    txSig = fmmod(dataSym,Fc,Fs,freqdev);
        
    for n = 1:length(EbNoVec)
    % Convert Eb/No to SNR
        k = 1;
        snrdB = EbNoVec(n) + 10*log10(k);
        rxSig = awgn(txSig,snrdB,'measured');
        
        % Demodulate the noisy signal
        rxSym(n,:) = fmdemod(rxSig,Fc,Fs,freqdev);
        
     end

figure(2)
plot(dataSym(1:1000), "LineWidth", 4)
hold on
for k=1:length(EbNoVec)
plot(rxSym(k,1:1000), ":", "LineWidth", 0.5)
end
title("Transmitted and Received AFSK FM")
legend("Transmitted","Received with SNR = 1 dB", "SNR = 2dB", "SNR = 3 dB", "SNR = 4dB", "SNR = 5dB")
hold off
