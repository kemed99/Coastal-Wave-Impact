# Coastal Wave Impact Timing Predictor - FSM Implementation

Repositori ini berisi implementasi Finite State Machine (FSM) untuk sistem prediksi dampak gelombang pesisir. Proyek ini menggabungkan logika sensor multispektral dan aktuator mitigasi bencana.

## 📂 Struktur File
- `CoastalFSM.v`: Modul utama desain FSM (Verilog).
- `CoastalFSM_tb.v`: Testbench untuk simulasi logika transisi state.
- `State_Diagram_FSM.png`: Visualisasi alur kerja state (Normal, Waspada, Bahaya).

## 📊 State Diagram
Berikut adalah logika transisi yang digunakan dalam sistem:

![State Diagram FSM](State_Diagram_FSM.png)
*(Pastikan nama file gambar di atas sesuai dengan nama file yang Anda upload)*

## ⚙️ Cara Menjalankan Simulasi (Icarus Verilog)

1. **Kompilasi kode:**
   ```bash
   iverilog -o FSM_sim CoastalFSM.v CoastalFSM_tb.v
   
2. **Jalankan Simulasi:**
    ```bash
   vvp FSM_sim

3. **Lihat grafik gelombang (Waveform):**
    ```bash
    gtkwave CoastalFSM_tb.vcd

📝 Deskripsi State
S0 (AMAN): Semua sensor dalam batas normal. Output aktuator OFF.

S1 (WASPADA): Terdeteksi risiko (X=1) tetapi belum kritis. Aktuator investigasi (Kamera, Arm) ON.

S2 (KRISIS TOTAL): Terdeteksi risiko fatal (C=1). Aktuator mitigasi (Buzzer, Pompa) ON.

Nama: Zhafran Ahmed 
