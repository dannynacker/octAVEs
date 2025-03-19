# octAVEs
Optimized Chronometric Transposition for AudioVisual Entrainment Systems

The octAVEs is a versatile Python tool designed to convert audio files into control parameters for audiovisual strobe devices. It extracts spectral information from an audio file, scales and maps frequencies into musical intervals, and outputs the results in formats compatible with two device types:

SCCS – which uses a CSV file for MATLAB-based workflows.
RX1 – which requires an STP (text) file for its operation.

Key Features

Spectral Extraction:
Uses a Short-Time Fourier Transform (STFT) to analyze the audio file and extract prominent frequency peaks. The user specifies how many channels (1–4) to extract.

Musical Transposition:
Maps extracted frequencies into the specified musical interval (e.g., Minor Third, Perfect Fourth) and direction (Unison, Up, or Down).

Dynamic Amplitude Scaling:
Scales raw amplitude values into two ranges:

0–255 for SCCS output.
0–100 for RX1 output.
Dwell Time Grouping (Resolution Adjustment):

Manual Grouping: The user may specify a “dwell time” (in seconds) to group multiple high-resolution time steps into a single aggregated step.
Forced Grouping: If the default 100 ms resolution yields more than 3,000 steps (exceeding RX1’s capacity), the script automatically computes a dwell time that brings the total step count within limits.
The grouping aggregates frequency, amplitude, and duty cycle parameters—averaging them or splitting them into start and end values (for dwell times of 1 second or more) to allow smooth interpolation.
Output Files:
The script saves two CSV files:

The original high-resolution CSV ([filename]_original.csv).
A grouped CSV ([filename]_grouped.csv) if dwell grouping is applied.
For RX1, the grouped data is further used to create an STP text file ([filename]_stp.txt).

User Input Validation:
All user inputs (except file paths/names) are validated. The script repeatedly prompts for input until a valid response is provided (for example, ensuring transposition direction is only 0, 1, or 2, and yes/no answers are "y" or "n").

Visualization:
A plot is generated to display the evolution of frequency and brightness/duty cycle over time, allowing for quick visual analysis of the spectral and dynamic behavior.

How It Works

Audio Processing and Spectral Extraction:
The script loads an audio file using librosa and computes the STFT. It extracts prominent frequency peaks (up to the specified channel count) for each time slice, and computes corresponding parameters (frequency, amplitude, note, and deviation). These values are scaled into the alpha band using a predefined frequency mapping.

Dynamic Amplitude Scaling:
The extracted amplitudes are dynamically scaled to produce two sets of columns:

SCCS Amplitudes: Scaled to a range of 0–255.
RX1 Amplitudes: Scaled to a range of 0–100.
The script handles both the regular (high-resolution) and the interpolated (grouped) modes seamlessly.

Dwell Time Grouping (Resolution Adjustment):

The user is prompted whether to manually apply dwell grouping.
If manual grouping is chosen, the user specifies the dwell time (or "min" for no grouping).
If manual grouping is declined but the default resolution (100 ms per step) results in more than 3,000 steps, the script forces dwell grouping by automatically calculating a new dwell time.
Grouping aggregates data within each dwell period (averaging for short dwell times or splitting into start/end values for dwell times ≥ 1 second) to produce fewer steps while preserving essential dynamics.
Channel Duplication:
Depending on the chosen channel mapping mode (1 channel to all 4, 2 channels, or all 4 channels independently), the script duplicates channels accordingly to fit the device’s 4 oscillator slots.

CSV and STP File Generation:

The original high-resolution data is saved as [filename]_original.csv.
If dwell grouping is applied (manually or forced), a grouped CSV ([filename]_grouped.csv) is also saved.
For RX1 output, the grouped data (or original if grouping wasn’t needed) is further processed to generate an STP text file ([filename]_stp.txt), ensuring that the number of steps does not exceed the RX1 device’s limits.
Plotting:
Finally, the script plots the behavior over time, showing frequency curves and duty cycle/brightness curves for each channel.

Intended Use

This script is ideal for artists, designers, and researchers who wish to convert audio into dynamic visual control data for strobe devices. It provides a flexible and user-friendly method to bridge audio processing and visual output, ensuring that device limitations are met while retaining creative control over the audiovisual transformation.

Usage

Run the script.
When prompted, enter the path to your audio file.
Specify the number of spectral channels to extract (1–4).
Choose the transposition direction (0 = Unison, 1 = Up, 2 = Down) and a musical interval.
Decide whether to invert the duty cycle.
Select the channel mapping mode (1, 2, or 4).
Choose the device output:
SCCS (CSV output for MATLAB)
RX1 (STP text file output)
Provide an output file name.
For RX1, decide whether to apply dwell grouping manually. If you decline and the default resolution exceeds RX1’s 3000-step limit, the script will automatically force grouping.
The script will create the original and (if applicable) grouped CSV files, generate an STP file (for RX1), and display a plot of the extracted behavior.

Conclusion

The octAVEs script offers a robust and flexible workflow for converting audio files into control parameters for strobe devices. By managing resolution through dwell time grouping and providing thorough input validation and output visualization, the script enables a smooth transition from audio signal to visual performance. Whether you need the granular detail of the original data or a grouped version tailored for device constraints, this tool is designed to meet your creative and technical requirements.
