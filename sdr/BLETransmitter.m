%% Bluetooth LE Waveform Generation and Transmission Using SDR
% This example shows how to implement a Bluetooth(R) Low Energy (LE)
% transmitter using the Bluetooth(R) Library. You can either transmit
% Bluetooth LE signals using the ADALM-PLUTO radio or write to a baseband
% file (*.bb). The transmitted Bluetooth LE signal can be received by the
% companion example, <docid:bluetooth_ug#mw_6d51b376-e768-4ddd-9d3c-8cd2140be482 
% Bluetooth Low Energy Receiver>, with any one of the
% following setup: (i) Two SDR platforms connected to the same host
% computer which runs two MATLAB sessions (ii) Two SDR platforms connected
% to two computers which run separate MATLAB sessions.
%
% Refer to the <docid:plutoradio_ug#bvn89q2-14 Guided Host-Radio Hardware Setup> documentation for details
% on how to configure your host computer to work with the Support Package
% for ADALM-PLUTO Radio.

% Copyright 2019-2022 The MathWorks, Inc.

%% Required Hardware and Software
% To transmit signals in real time, you need ADALM-PLUTO radio and the
% corresponding support package Add-On:
%
% * <https://www.mathworks.com/hardware-support/adalm-pluto-radio.html
% Communications Toolbox Support Package for ADALM-PLUTO Radio>
%
% For a full list of Communications Toolbox supported SDR platforms, refer
% to Supported Hardware section of the
% <https://www.mathworks.com/discovery/sdr.html Software Defined Radio
% (SDR) discovery page>.

%% Background
% The Bluetooth Special Interest Group (SIG) introduced Bluetooth LE for
% low power short range communications. The Bluetooth standard
% specifies the *Link* layer which includes both *PHY* and *MAC* layers.
% Bluetooth LE applications include image and video file transfers between
% mobile phones, home automation, and the Internet of Things (IoT).
%
% Specifications of Bluetooth LE:
%
% * *Transmission frequency range*: 2.4-2.4835 GHz
% * *RF channels* : 40
% * *Symbol rate* : 1 Msym/s, 2 Msym/s
% * *Modulation* : Gaussian Minimum Shift Keying (GMSK)
% * *PHY transmission modes* : (i) LE1M - Uncoded PHY with data rate of 1
% Mbps (ii) LE2M - Uncoded PHY with data rate of 2 Mbps (iii) LE500K -
% Coded PHY with data rate of 500 Kbps (iv) LE125K - Coded PHY with data
% rate of 125 Kbps
%
% The Bluetooth standard specifies air interface packet formats
% for all the four PHY transmission modes of Bluetooth LE using the
% following fields:
%
% * *Preamble*: The preamble depends on PHY transmission mode. LE1M mode
% uses an 8-bit sequence of alternate zeros and ones, '01010101'. LE2M uses
% a 16-bit sequence of alternate zeros and ones, '0101...'. LE500K and
% LE125K modes use an 80-bit sequence of zeros and ones obtained by
% repeating '00111100' ten times.
% * *Access Address*: Specifies the connection address shared between two
% Bluetooth LE devices using a 32-bit sequence.
% * *Coding Indicator*: 2-bit sequence used for differentiating coded modes
% (LE125K and LE500K).
% * *Payload*: Input message bits including both protocol data unit (PDU)
% and cyclic redundancy check (CRC). The maximum message size is 2080 bits.
% * *Termination Fields*: Two 3-bit vectors of zeros, used in forward error
% correction encoding. The termination fields are present for coded modes
% (LE500K and LE125K) only.
%
% Packet format for uncoded PHY (LE1M and LE2M) modes is shown in the
% figure below:
%
% <<../BLEUncodedPhy.png>>
%
% Packet format for coded PHY (LE500K and LE125K) modes is shown in the
% figure below:
%
% <<../BLECodedPhy.png>>

%% Example Structure
% The general structure of the Bluetooth LE transmitter example is
% described as follows:
%
% # Generate link layer PDUs
% # Generate baseband IQ waveforms
% # Transmitter processing

%%
% *Generate Link Layer PDUs*
%
% Link layer PDUs can be either advertising channel PDUs or data channel
% PDUs. You can configure and generate advertising channel PDUs using
% <docid:bluetooth_ref#obj_bleLLAdvertisingChannelPDUConfig bleLLAdvertisingChannelPDUConfig> and
% <docid:bluetooth_ref#mw_fccd1d53-97fd-42f0-bc75-3dcc8a93ca5e bleLLAdvertisingChannelPDU>
% functions respectively. You can configure and generate data channel PDUs
% using <docid:bluetooth_ref#obj_bleLLDataChannelPDUConfig bleLLDataChannelPDUConfig> and <docid:bluetooth_ref#mw_0309e66e-dc52-4189-872e-2523a76669de bleLLAdvertisingChannelPDUDecode> functions respectively.

% Configure an advertising channel PDU
cfgLLAdv = bleLLAdvertisingChannelPDUConfig;
cfgLLAdv.PDUType         = 'Advertising indication';
cfgLLAdv.AdvertisingData = '0123456789ABCDEF';
cfgLLAdv.AdvertiserAddress = '1234567890AB';

% Generate an advertising channel PDU
messageBits = bleLLAdvertisingChannelPDU(cfgLLAdv);

%%
% *Generate Baseband IQ Waveforms*
%
% You can use the <docid:bluetooth_ref#fcn_bleWaveformGenerator bleWaveformGenerator> function to generate standard-compliant waveforms.

phyMode = 'LE1M'; % Select one mode from the set {'LE1M','LE2M','LE500K','LE125K'}
sps = 8;          % Samples per symbol
channelIndex = 37;  % Channel index value in the range [0,39]
accessAddressLen = 32;% Length of access address
accessAddressHex = '8E89BED6';  % Access address value in hexadecimal
accessAddressBin = int2bit(hex2dec(accessAddressHex),accessAddressLen,false); % Access address in binary

% Symbol rate based on |'Mode'|
symbolRate = 1e6;
if strcmp(phyMode,'LE2M')
    symbolRate = 2e6;
end

% Generate Bluetooth LE waveform
txWaveform = bleWaveformGenerator(messageBits,...
    'Mode',            phyMode,...
    'SamplesPerSymbol',sps,...
    'ChannelIndex',    channelIndex,...
    'AccessAddress',   accessAddressBin);

% Set up spectrum viewer
spectrumScope = spectrumAnalyzer('Method','welch', ...
    'SampleRate',       symbolRate*sps,...
    'SpectrumType',     'Power density', ...
    'SpectralAverages', 10, ...
    'YLimits',          [-130 0], ...
    'Title',            'Baseband Bluetooth LE Signal Spectrum', ...
    'YLabel',           'Power spectral density');

% Show power spectral density of the Bluetooth LE signal
spectrumScope(txWaveform);

%%
% *Transmitter Processing*
%
% Specify the signal sink as 'File' or 'ADALM-PLUTO'.
%
% * *File*:Uses the <docid:comm_ref#bvby020-1 comm.BasebandFileWriter> to
% write a baseband file.
% * *ADALM-PLUTO*: Uses the <docid:plutoradio_ref#bvn84t3-1 sdrtx> System
% object to transmit a live signal from the SDR hardware.

%%

% Initialize the parameters required for signal source
txCenterFrequency       = 2.402e9;  % Varies based on channel index value
txFrameLength           = length(txWaveform);
txNumberOfFrames        = 1e4;
txFrontEndSampleRate    = symbolRate*sps;

% The default signal source is 'File'
signalSink = 'File';

if strcmp(signalSink,'File')
    
    sigSink = comm.BasebandFileWriter('CenterFrequency',txCenterFrequency,...
        'Filename','bleCaptures.bb',...
        'SampleRate',txFrontEndSampleRate);
    sigSink(txWaveform); % Writing to a baseband file 'bleCaptures.bb'
    
elseif strcmp(signalSink,'ADALM-PLUTO')
    
    % First check if the HSP exists
    if isempty(which('plutoradio.internal.getRootDir'))
		link = sprintf('<a href="https://www.mathworks.com/hardware-support/adalm-pluto-radio.html"> ADALM-PLUTO Radio Support From Communications Toolbox</a>');
        error('Unable to find Communications Toolbox Support Package for ADALM-PLUTO Radio. To install the support package, visit %s.', link);
    end
    connectedRadios = findPlutoRadio; % Discover ADALM-PLUTO radio(s) connected to your computer
    radioID = connectedRadios(1).RadioID;
    sigSink = sdrtx( 'Pluto',...
        'RadioID',           radioID,...
        'CenterFrequency',   txCenterFrequency,...
        'Gain',              0,...
        'SamplesPerFrame',   txFrameLength,...
        'BasebandSampleRate',txFrontEndSampleRate);
    % The transfer of baseband data to the SDR hardware is enclosed in a
    % try/catch block. This means that if an error occurs during the
    % transmission, the hardware resources used by the SDR System
    % object(TM) are released.
    currentFrame = 1;
    try
        while currentFrame <= txNumberOfFrames
            % Data transmission
            sigSink(txWaveform);
            % Update the counter
            currentFrame = currentFrame + 1;
        end
    catch ME
        release(sigSink);
        rethrow(ME)
    end
else
    error('Invalid signal sink. Valid entries are File and ADALM-PLUTO.');
end

% Release the signal sink
release(sigSink)

%% Further Exploration
% The companion example <docid:bluetooth_ug#mw_6d51b376-e768-4ddd-9d3c-8cd2140be482
% Bluetooth LE Waveform Reception Using SDR> can be used to decode the
% waveform transmitted by this example. You can also use this example to
% transmit the data channel PDUs by changing channel index, access address
% and center frequency values in both the examples.

%% Troubleshooting
% General tips for troubleshooting SDR hardware and the Communications
% Toolbox Support Package for ADALM-PLUTO Radio can be found in
% <docid:plutoradio_ug#bvn89q2-68 Common Problems and Fixes>.

%% Selected Bibliography
% # Bluetooth Technology Website | The Official Website of Bluetooth
% Technology, Accessed November 22, 2021. https://www.bluetooth.com.
% # Volume 6 of the Bluetooth Core Specification, Version 5.3 Core System
% Package [Low Energy Controller Volume].
