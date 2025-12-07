// Modul FSM untuk Coastal Wave Impact Predictor
module CoastalFSM (
    input clk,          // Clock
    input reset,        // Sinyal reset asinkron
    input X,            // Input X (Risiko Apapun = H+F+T+I+R+D)
    input C_Total,      // Input C_Total (Krisis Total = H.F.T.I.R.D)
    
    // Output FSM (Status Aktuator yang Dikelompokkan)
    output reg O_Kritis,      // Output untuk Krisis (Buzzer, dll.)
    output reg O_Investigasi  // Output untuk Investigasi (MA, FW, SHT)
);

// Definisi state menggunakan parameter
parameter S0_AMAN     = 2'b00;  // NORMAL
parameter S1_WASPADA  = 2'b01;  // PERINGATAN
parameter S2_BAHAYA   = 2'b10;  // KRISIS TOTAL

reg [1:0] current_state;
reg [1:0] next_state;

// Logika Sekuensial: Pembaruan state
always @(posedge clk or posedge reset) begin
    if (reset)
        current_state <= S0_AMAN;
    else
        current_state <= next_state;
end

// Logika Kombinasional: Tabel Transisi Status (Step 3 yang dikoreksi)
always @(*) begin
    next_state = current_state; // Default: Tetap di state saat ini
    
    case (current_state)
        S0_AMAN: begin
            if (C_Total) next_state = S2_BAHAYA; // 00 -> 10 (Krisis)
            else if (X)   next_state = S1_WASPADA; // 00 -> 01 (Peringatan)
        end
        
        S1_WASPADA: begin
            if (C_Total) next_state = S2_BAHAYA; // 01 -> 10 (Krisis)
            else if (!X) next_state = S0_AMAN;   // 01 -> 00 (Kembali Normal)
            // else jika X=1 & C_Total=0, tetap di S1_WASPADA
        end
        
        S2_BAHAYA: begin
            if (!X) next_state = S0_AMAN; // 10 -> 00 (Kembali Normal)
            else if (!C_Total) next_state = S1_WASPADA; // 10 -> 01 (Krisis Mereda)
            // else jika X=1 & C_Total=1, tetap di S2_BAHAYA
        end
        
        default: next_state = S0_AMAN;
    endcase
end

// Logika Output: Berdasarkan Status Saat Ini (Moore Machine)
always @(current_state) begin
    O_Kritis = 0;
    O_Investigasi = 0;

    case (current_state)
        S0_AMAN: begin
            O_Kritis = 0;
            O_Investigasi = 0;
        end
        S1_WASPADA: begin
            O_Kritis = 0;
            O_Investigasi = 1; // Aktifkan MA, FW, SHT
        end
        S2_BAHAYA: begin
            O_Kritis = 1;      // Aktifkan Buzzer
            O_Investigasi = 1; // Aktifkan MA, FW, SHT
        end
        default: begin
            O_Kritis = 0;
            O_Investigasi = 0;
        end
    endcase
end

endmodule