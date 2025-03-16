# BDS-B2b-SDR

Thanks to its high cost-effectiveness and flexibility, Global Navigation Satellite System (GNSS) Software-Defined Receiver (SDR) has been widely used in the GNSS academic research and industrial developments. As a pivotal component of the Chinese BeiDou Navigation Satellite System (BDS) navigation satellite signal portfolio, the B2b signal is newly introduced and disseminated by the third generation of BDS (BDS-3) satellites, which provides both Radio Navigation Satellite System (RNSS) service as well as the Precise Point Positioning (PPP-B2b) service. To promote the research and application of BDS-3 B2b signals, we developed and open-sourced a MATLAB package for BDS B2b signal processing functionalities, including display, acquisition, tracking, telemetry decoding, and positioning. The developed BDS B2b SDR features and code architecture are introduced in details, and sample datasets are collected for performance assessment.

# Features

##	Raw signal datasets loading and visualization;

##	Acquisition and tracking of B2b signals from BDS MEO/IGSO/GEO satellites;

##	Decoding of both BDS B-CNAV3 and PPP-B2b State Space Representation (SSR) messages;

##	Implementation of BeiDou Global Ionospheric delay correction Model (BDSGIM);

##	Code-based positioning with broadcast navigation ephemeris or with PPP-B2b SSR ephemeris;

##	Computation and output of PPP-B2b precise ephemeris to standard SP3 files; 

##	Supports for BeiDou Coordinate System (BDCS).

# Contact
zhou.peiyuan@outlook.com

# Other resources
Interested users could refer to https://github.com/gnsscusdr/CU-SDR-Collection for the processing of other GNSS signals.
