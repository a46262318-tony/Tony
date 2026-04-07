#ifndef READCSV_H
#define READCSV_H
#include <cstdint>

struct Ipp64fc {
    double re;
    double im;
};

struct HeaderData {
    uint32_t sop;
    int Source_CSCI_ID;
    int Destination_CSCI_ID;
    int Source_sub_subsystem_ID1;
    int Source_subsystem_ID2;
    int Destination_sub_subsystem_ID1;
    int Destination_subsystem_ID2;
    int Message_Length;
    int Message_Counter;
    int Command_ID;
    int Data_Ack;
    int Reserved1;
    int Dwell_ID;
    int Frequency_Code;
    int Waveform_Type;
    int Reserved2;
    int Sampling_ID;
    int Reserved3;
    int Reserved4;
    int Reserved5;
    int Reserved6;
    int Azimuth_Encoder;
    int Elevation_Encoder;
    uint64_t Time_Stamp;
    int NFFT_1;
    int NFFT_2;
    int NFFT_3;
    int NFFT_4;
};

void socket_process(const HeaderData& hdata, Ipp64fc* tr, Ipp64fc* tl, Ipp64fc* br, Ipp64fc* bl);
void readAllCSVsAndProcessCUDA();

#endif // READCSV_H
