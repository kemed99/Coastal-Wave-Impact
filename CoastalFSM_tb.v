`timescale 1ns / 1ps

module CoastalFSM_tb;

    // Deklarasi Sinyal (Wires/Regs) yang menghubungkan ke modul FSM
    reg clk;
    reg reset;
    reg X;          // Input Risiko Apapun (X = H+F+T+I+R+D)
    reg C_Total;    // Input Krisis Total (C_Total = H.F.T.I.R.D)
    
    wire O_Kritis;
    wire O_Investigasi;

    // Inisialisasi parameter Waktu
    parameter CLK_PERIOD = 10; // Periode clock = 10ns (Frekuensi 100MHz)

    // 1. Instansiasi Modul Desain (UUT: Unit Under Test)
    CoastalFSM UUT (
        .clk(clk),
        .reset(reset),
        .X(X),
        .C_Total(C_Total),
        .O_Kritis(O_Kritis),
        .O_Investigasi(O_Investigasi)
    );

    // 2. Clock Generation
    // Hasilkan sinyal clock dengan duty cycle 50%
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk; 
    end

    // 3. Stimulus Generation (Sekuens Uji)
    initial begin
        // Inisialisasi Awal
        reset = 1;
        X = 0;
        C_Total = 0;
        
        // Mulai Dumpsing VCD (untuk visualisasi waveform)
        $dumpfile("CoastalFSM_tb.vcd");
        $dumpvars(0, CoastalFSM_tb); 

        // Tahan reset selama 20 ns
        #(2*CLK_PERIOD) reset = 0; 
        
        // Uji Skenario Transisi

        // --- Skenario 1: S0 (NORMAL) -> S1 (WASPADA) -> S0 (NORMAL)
        #(CLK_PERIOD); // Tunggu stabil di S0
        $display("Time %0t: S0 -> S1 (Peringatan Awal)", $time);
        X = 1; C_Total = 0; // Risiko Terdeteksi, Bukan Krisis
        
        #(5*CLK_PERIOD); 
        $display("Time %0t: S1 -> S0 (Kembali Normal)", $time);
        X = 0; C_Total = 0; // Risiko Hilang
        
        // --- Skenario 2: S0 (NORMAL) -> S2 (KRISIS TOTAL)
        #(5*CLK_PERIOD); 
        $display("Time %0t: S0 -> S2 (Krisis Penuh)", $time);
        X = 1; C_Total = 1; // Semua Risiko Kritis ON
        
        // --- Skenario 3: S2 (KRISIS TOTAL) -> S1 (KRISIS MEREDA)
        #(5*CLK_PERIOD); 
        $display("Time %0t: S2 -> S1 (Krisis Mereda)", $time);
        X = 1; C_Total = 0; // Risiko Masih Ada (X=1) tapi Krisis Total OFF (C_Total=0)

        // --- Skenario 4: S1 (WASPADA) -> S2 (KRISIS)
        #(5*CLK_PERIOD); 
        $display("Time %0t: S1 -> S2 (Krisis Kembali)", $time);
        X = 1; C_Total = 1; // Kembali ke Krisis Total

        // --- Skenario 5: S2 (KRISIS) -> S0 (RESET PENUH)
        #(5*CLK_PERIOD);
        $display("Time %0t: S2 -> S0 (Emergency Reset)", $time);
        X = 0; C_Total = 0; // Semua Risiko Mati

        // Akhiri Simulasi
        #(10*CLK_PERIOD) $finish;
    end

endmodule