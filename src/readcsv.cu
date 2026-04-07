#include <iostream>   // std::cout, std::cerr
#include <fstream>    // std::ifstream
#include <sstream>    // std::stringstream
#include <string>     // std::string
#include <thread>     // std::thread
#include "readcsv.h" // struct Ipp64fc {
#include <charconv>
#include <algorithm> // for std::find
#include <vector>   // <-- ADD THIS
#include <chrono>  // For timing

void socket_process(const HeaderData& hdata,
                    Ipp64fc* tr,
                    Ipp64fc* tl,
                    Ipp64fc* br,
                    Ipp64fc* bl)
{
    std::cout << "socket_process called\n";
}

void readAllCSVsAndProcessCUDA() {
    HeaderData hdata{
        .sop = 0xAABBCCDD,
                .Source_CSCI_ID = 1,
                .Destination_CSCI_ID = 2,
                .Source_sub_subsystem_ID1 = 3,
                .Source_subsystem_ID2 = 4,
                .Destination_sub_subsystem_ID1 = 5,
                .Destination_subsystem_ID2 = 6,
                .Message_Length = 20,
                .Message_Counter = 30,
                .Command_ID = 40,
                .Data_Ack = 0,
                .Reserved1 = 0,
                .Dwell_ID = 10,
                .Frequency_Code = 0,
                .Waveform_Type =0,
                .Reserved2 = 0,
                .Sampling_ID = 0,
                .Reserved3 = 0,
                .Reserved4 = 0,
                .Reserved5 = 0,
                .Reserved6 = 0,
                .Azimuth_Encoder = 1234,
                .Elevation_Encoder = 5678,
                .Time_Stamp = 0x5F5E100,
                .NFFT_1 = 14916,
                .NFFT_2 = 14916,
                .NFFT_3 = 14916,
                .NFFT_4 = 14916
    };
std::cout << "Waveform_Type: " << hdata.Waveform_Type << std::endl;

    int nfft = 180000;//hdata.NFFT_1;

    // Allocate memory using IPP
    std::vector<Ipp64fc> IQ_tr_up1(nfft);
    std::vector<Ipp64fc> IQ_tl_up1(nfft);
    std::vector<Ipp64fc> IQ_br_up1(nfft);
    std::vector<Ipp64fc> IQ_bl_up1(nfft);

    // Lambda to read CSV into Ipp64fc array
    
auto reader = [&](const std::string& filename, Ipp64fc* buf) {
    auto start = std::chrono::high_resolution_clock::now(); // start timer
    try {
        std::ifstream file(filename);
        if (!file.is_open()) {
            std::cerr << "Failed to open " << filename << "\n";
            return;
        }

        std::string line;
        std::getline(file, line); // skip header

        int index = 0;
        while (std::getline(file, line) && index < nfft) {
            const char* ptr = line.c_str();
            const char* end = ptr + line.size();
            const char* comma1 = std::find(ptr, end, ',');
            if (comma1 == end) continue;
            const char* real_start = comma1 + 1;
            const char* comma2 = std::find(real_start, end, ',');
            if (comma2 == end) continue;
            const char* imag_start = comma2 + 1;

            double real = 0.0, imag = 0.0;
            auto res1 = std::from_chars(real_start, comma2, real);
            if (res1.ec != std::errc()) continue;
            auto res2 = std::from_chars(imag_start, end, imag);
            if (res2.ec != std::errc()) continue;

            buf[index].re = real;
            buf[index].im = imag;
            ++index;
        }

        auto end = std::chrono::high_resolution_clock::now();
        double elapsed_ms = std::chrono::duration<double, std::milli>(end - start).count();
        std::cout << "Finished reading " << filename 
                  << " (" << index << " entries) in " << elapsed_ms << " ms\n";

    } catch (const std::exception& e) {
        std::cerr << "Exception while reading " << filename << ": " << e.what() << "\n";
    }
};

    // --- Start total timer ---
    auto start_total = std::chrono::high_resolution_clock::now();

    // Start threads
    std::string basePath = "/home/srts/Pictures/RC/MAGnitude_20260303/MAGnitude/mag_93db_1/";
    std::thread t1(reader, basePath + "Q1.csv", IQ_tr_up1.data());
    std::thread t2(reader, basePath + "Q2.csv", IQ_tl_up1.data());
    std::thread t3(reader, basePath + "Q3.csv", IQ_br_up1.data());
    std::thread t4(reader, basePath + "Q4.csv", IQ_bl_up1.data());

    // Wait for all threads to finish
    t1.join(); t2.join(); t3.join(); t4.join();

    // --- End total timer ---
    auto end_total = std::chrono::high_resolution_clock::now();
    double total_ms = std::chrono::duration<double, std::milli>(end_total - start_total).count();
    std::cout << "Total CSV reading time: " << total_ms << " ms\n";

    std::cout << "CSV reading done\n";

    std::cout << "TR CH: " << IQ_tr_up1[10].re << ", " << IQ_tr_up1[10].im << std::endl;
    std::cout << "TL CH: " << IQ_tl_up1[10].re << ", " << IQ_tl_up1[10].im << std::endl;
    std::cout << "BR CH: " << IQ_br_up1[10].re << ", " << IQ_br_up1[10].im << std::endl;
    std::cout << "BL CH: " << IQ_bl_up1[10].re << ", " << IQ_bl_up1[10].im << std::endl;

    std::cout << "CUDA processing done\n";

    socket_process(hdata,
                IQ_tr_up1.data(),
                IQ_tl_up1.data(),
                IQ_br_up1.data(),
                IQ_bl_up1.data());
}
