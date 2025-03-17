# octAVEs
Optimized Chronometric Transposition for AudioVisual Entrainment Systems

Omni Spectral Strobe Script

This repository contains a fully integrated Python script that extracts spectral data from an audio file and prepares output for two stroboscope systems: SCCS and RX1. The script supports a flexible workflow by allowing the user to specify:

The number of channels to extract (1, 2, 3, or 4) via FFT peak–detection.
The desired transposition interval and direction (Unison, Up, or Down for any musical interval from 0 to 12).
Whether the duty cycle should be inverted.
The channel mapping mode (i.e. whether to duplicate a single channel, split two channels across outputs, or use all four independently).
Based on these selections, the script:

Extracts candidate frequency peaks using Librosa’s STFT.
Computes note names and deviation values using an extended frequency mapping (from C–5 to B–15).
Scales frequencies into a target “alpha band” using a pre‐defined frequency array.
Generates transposed frequencies (both Up and Down) for every candidate across all intervals.
Normalizes amplitude values into two scales:
0–255 for the SCCS device (CSV output).
0–100 for the RX1 device (STP text output).
Duplicates channel data as needed based on the user–selected mapping mode.
Interpolates the data at 2000 Hz, rotates candidate channels randomly each second, and generates a square–wave LED pattern.
Packages the LED pattern and DAC brightness data into a 1D array for device loading.
Produces both an overlay plot and a 2×2 subplot view for visual inspection.
For SCCS, the output is a CSV file that contains all extracted spectral information, including all transposition columns and separate amplitude columns. For RX1, the script converts the CSV into an STP–formatted text file that uses the frequency columns corresponding to the selected transposition and the RX1 amplitude columns.

Features

Spectral Extraction:
Uses FFT and peak detection to extract up to four distinct frequency peaks per time slice.

Note Mapping:
Computes the closest musical note and deviation using a full extended frequency mapping.

Transposition:
Calculates both Up and Down transpositions for every musical interval (Unison through Octave) and stores them as separate columns.

Amplitude Scaling:
Normalizes raw amplitude data to 0–255 for SCCS and to 0–100 for RX1.

Flexible Channel Mapping:
Supports mapping modes to duplicate channels as needed so that the output always has four channels.

Interpolation & Rotation:
Interpolates the extracted data at a 2000 Hz sample rate and applies random channel rotation each second for dynamic LED assignment.

LED Pattern Generation:
Generates a square–wave LED “on” pattern using the instantaneous frequency and a dynamic duty cycle (computed from the scaled amplitude).

Device Output:

SCCS: Outputs a CSV file that can be directly used by a MATLAB script for the SCCS device.
RX1: Generates an STP–formatted text file that uses the selected transposition columns and RX1 amplitude values.
Visualization:
Provides two types of plots:

An overlay plot showing frequency and duty cycle behavior.
A 2×2 tiled subplot view for individual channel inspection.
Requirements
Python 3.x
Libraries: numpy, pandas, librosa, scipy, matplotlib
A valid audio file (e.g., MP3) to process.
MATLAB (for SCCS interface using the CSV output) and your device-specific loading function (SCCS_strobe_load_device).
Usage
Run the Script:
Execute the Python script. You will be prompted for:

The path to your audio file.
The number of channels to extract (1, 2, 3, or 4).
The transposition direction (0 for Unison, 1 for Up, 2 for Down).
The musical interval (choose from the provided list).
Whether to invert the duty cycle (y/n).
The channel mapping mode:
(1) Use one extracted channel for all outputs.
(2) Use two extracted channels (channel 1 for outputs 1–2, channel 2 for outputs 3–4).
(4) Use all four extracted channels.
The desired device output:
(1) SCCS (CSV output for MATLAB interface)
(2) RX1 (STP text file output)
The desired output file name (without extension).
Output Files:

If SCCS is selected, a CSV file (e.g., my_output.csv) will be created with full spectral and transposition data.
If RX1 is selected, an STP file (e.g., my_output_stp.txt) will be generated using the selected transposition columns and amplitude values scaled to 0–100.
Visualization:
The script will generate two plots to allow you to inspect the extracted frequency and duty cycle behavior.

Device Loading:
Finally, the script calls your SCCS device–loading function to send the prepared 1D data array to the hardware.

How It Works

Spectral Extraction:
The script uses Librosa to compute the STFT of the input audio. It then detects prominent peaks (above 10% of the maximum amplitude) in each time slice, calculates note and deviation information, and scales the detected frequency into a specified octave range (the alpha band).

Transposition & Amplitude Scaling:
For each candidate frequency, the script computes transpositions (both Up and Down) for every musical interval. The raw amplitude is scaled to two ranges: 0–255 (for SCCS) and 0–100 (for RX1).

Channel Mapping & Rotation:
Based on the user's channel mapping mode, the extracted channels are duplicated as needed so that four outputs are always provided. The script then randomly assigns the candidate channels to the four physical LED ring channels on a per-second basis.

LED Pattern & Data Packaging:
A square–wave LED pattern is generated using the instantaneous frequency and a dynamic duty cycle computed from the amplitude. The center LED is forced off, and the resulting LED pattern and DAC brightness data are packaged into a 1D array for device loading.
