# octAVEs & autoTUNE: Audio-to-Strobe Conversion Tools

This project offers two complementary pipelines for converting audio files into control parameters for audiovisual strobe devices. The tools are designed to extract spectral information from an audio file, map frequencies into musical intervals, and generate output files compatible with two types of devices:

SCCS – which uses a CSV file for MATLAB-based workflows.

RX1 – which requires an STP (text) file for its operation.

Both pipelines share a similar workflow in terms of amplitude scaling, dwell time grouping, channel mapping, and output generation, but they differ in the method of spectral extraction and frequency mapping.

# Overview
octAVEs (FFT-based Extraction)

Spectral Extraction:

Uses a Short-Time Fourier Transform (STFT) to analyze the audio file and extract prominent frequency peaks. The user specifies how many channels (1–4) to extract. The output frequencies are then scaled and mapped directly based on amplitude and predefined frequency mappings.

Musical Transposition:

Maps the extracted frequencies into the specified musical interval (e.g., Minor Third, Perfect Fourth) and direction (Unison, Up, or Down).

Dynamic Amplitude Scaling & Dwell Grouping:

Raw amplitude values are scaled into two ranges: 0–255 for SCCS output and 0–100 for RX1 output. The script also provides options for manual or automatic dwell time grouping to adjust the time resolution, ensuring compatibility with device step limits.

Output Files & Visualization:

The high-resolution spectral data is saved as [filename]_original.csv.

If dwell grouping is applied, a grouped CSV ([filename]_grouped.csv) is also created.

For RX1, an STP text file ([filename]_stp.txt) is generated.

A plot is produced to visualize frequency curves and duty cycle/brightness over time.

# autoTUNE (CQT-based Extraction)

Spectral Extraction with Musical Sensitivity:

autoTUNE employs the Constant Q Transform (CQT) instead of the FFT. Because CQT provides logarithmically spaced frequency bins that align with musical intervals, the extracted spectral peaks are automatically “tuned” to the strobe frequency of the nearest note.

Key Point: Rather than using the exact scaled frequency as in the FFT method, autoTUNE adjusts (“autotunes”) the data so that the output more closely follows a musical scale.

Adjustable Parameters:
The CQT pipeline allows you to adjust parameters such as:

fmin: The minimum frequency (e.g., corresponding to C1).

bins_per_octave: Typically set to 12 for semitone resolution.

n_bins: The total number of bins, which defines the overall musical range.

hop_length: Determines the time resolution.

While fixed parameters (like fmin = C1, bins_per_octave = 12, and a suitable n_bins for your desired range) work well for standard musical material, you may need dynamic or adaptive scaling for diverse audio content.

Similar Downstream Processing:

Like octAVEs, autoTUNE maps the “autotuned” frequencies into specified musical intervals, applies dynamic amplitude scaling, and handles dwell grouping and channel mapping. The output file formats and visualization remain consistent, ensuring a smooth workflow regardless of which extraction method is chosen.

# Key Features (Common to Both Pipelines)

Spectral Extraction:

octAVEs: Uses STFT to extract frequency peaks.

autoTUNE: Uses CQT to “autotune” spectral data to the nearest musical note.

Musical Transposition:

Extracted frequencies are mapped into the specified musical interval (e.g., Unison, Minor Third, Perfect Fifth) and direction (Up or Down).

Dynamic Amplitude Scaling:

Raw amplitude values are scaled into two ranges:

0–255 for SCCS output

0–100 for RX1 output

Dwell Time Grouping (Resolution Adjustment):

Manual Grouping: 
The user may specify a dwell time (in seconds) to group multiple high-resolution time slices into a single aggregated step.

Forced Grouping: 
If the default 100 ms resolution results in more than 3,000 steps (exceeding RX1’s capacity), the script automatically calculates a suitable dwell time.

Channel Duplication:

Based on the selected channel mapping mode (1 channel to all 4, 2 channels, or all 4 channels independently), the script duplicates channels accordingly to match the 4 oscillator slots on the device.

CSV and STP File Generation:

Original high-resolution data is saved as [filename]_original.csv.

A grouped CSV ([filename]_grouped.csv) is created when dwell grouping is applied.

For RX1 output, an STP text file ([filename]_stp.txt) is generated from the grouped or original data.

User Input Validation & Visualization:

User inputs are thoroughly validated. A plot is generated to display the evolution of frequency and brightness/duty cycle over time, aiding in quick visual analysis of the spectral and dynamic behavior.

# How It Works

Audio Processing and Spectral Extraction:

octAVEs loads the audio using librosa and computes the STFT, then extracts prominent peaks per time slice.

autoTUNE also loads the audio but uses librosa’s CQT to generate a spectrogram with logarithmically spaced bins. This results in spectral peaks that are automatically aligned (“autotuned”) to the nearest musical note.

Frequency Mapping & Transposition:

Both pipelines map the extracted frequencies into the desired musical interval using predefined frequency mappings and scaling functions.

Dynamic Amplitude Scaling:

Amplitude values are scaled dynamically for both SCCS (0–255) and RX1 (0–100) outputs.

Dwell Time Grouping:

The script groups data into dwell periods (manually specified or forced) to reduce the number of steps while preserving the essential dynamics. It averages or interpolates frequency, amplitude, and duty cycle parameters accordingly.

CSV and STP File Generation:

Depending on the chosen device output, the script saves the high-resolution data and/or grouped data as CSV files, and for RX1, converts the grouped data into an STP text file.

Plotting:

A visualization is generated to display the evolution of frequency and brightness/duty cycle over time, enabling quick assessment of the output’s behavior.

# Intended Use

These tools are ideal for artists, designers, and researchers who wish to convert audio into dynamic visual control data for strobe devices. Whether you prefer the precision of the FFT-based octAVEs or the musically sensitive, “autotuned” output of autoTUNE, the scripts provide a flexible and user-friendly method to bridge audio processing and visual performance while ensuring device constraints are met.

# Usage

Run the Script:

Execute the main script.

Provide Input When Prompted:

Enter the path to your audio file.

Specify the number of spectral channels to extract (1–4).

Choose the transposition direction (0 = Unison, 1 = Up, 2 = Down) and a musical interval.

Decide whether to invert the duty cycle.

Select the channel mapping mode (1, 2, or 4).

Choose the device output: SCCS (CSV output for MATLAB) or RX1 (STP text file output).

Provide an output file name.

For RX1 output, decide whether to apply dwell grouping manually. If declined and the default resolution exceeds RX1’s 3000-step limit, the script will automatically force grouping.

Select the Extraction Method:

Depending on your preference, you can choose between:

octAVEs: The FFT-based extraction.

autoTUNE: The CQT-based extraction which “autotunes” spectral peaks to the nearest musical note.
(You can set a flag or modify the script to call the desired extraction function.)

Review Outputs:

CSV files ([filename]_original.csv and optionally [filename]_grouped.csv) are generated.

For RX1 output, an STP file ([filename]_stp.txt) is created.

A plot displays the behavior over time.

# Conclusion

The octAVEs script provides a robust workflow for converting audio files into control parameters using FFT-based spectral extraction, while autoTUNE offers an alternative approach that leverages the Constant Q Transform to “autotune” spectral data to a musical scale. By offering dynamic amplitude scaling, flexible dwell time grouping, and thorough input validation with visualization, these tools enable a seamless transition from audio signal to visual performance. Choose the pipeline that best fits your musical and technical requirements, or experiment with both to see which output best aligns with your creative vision.
