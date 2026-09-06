
# 📡 Robust UART Controller Core in Verilog

[![Verilog](https://shields.io)](https://wikipedia.org)
[![Tool-Vivado](https://shields.io)](https://xilinx.com)
[![License: MIT](https://shields.io)](https://opensource.org)
[![Build-Status](https://shields.io)]()

A synthesizable, hardware-accurate **Universal Asynchronous Receiver-Transmitter (UART)** controller IP core designed from scratch in **Verilog HDL**. This architecture provides a fully decoupled, FSM-driven solution for serial-to-parallel and parallel-to-serial data boundaries over asynchronous networks.

Developed and verified inside **Xilinx Vivado** using a structural loopback top-level verification wrapper.

---

## 🛠️ Architecture & Core Features

*   **Modular Endpoint Partitioning:** Implements fully isolated, independent Transmitter (`uart_tx`) and Receiver (`uart_rx`) state engines.
*   **Glitch-Resilient Mid-Bit Sampling:** The receiver uses an internal sub-sampling architecture that captures input bits at precisely `Baud Count / 2` (center-aligned), preventing edge-settling line noise from corrupting data.
*   **Deterministic FSM Control:** Driven by strict, race-condition-free Finite State Machines controlling data streaming, framing wrappers, and interface lines.
*   **Standard 8-N-1 Packet Framing:** Hardened data structures supporting **1 Start Bit**, **8 Data Bits (transmitted LSB first)**, and **1 Stop Bit**.

---

## 📊 Protocol & Frame Specifications

| Parameter | Configuration Specification | Purpose / Notes |
| :--- | :--- | :--- |
| **Baud Rate** | Configurable (Default: 9600) | Synchronized via parameterized hardware counter |
| **Data Payload**| 8 Bits | Sent Least Significant Bit (LSB) first |
| **Parity Bit**  | None (`N`) | Optimized for high-throughput, raw payload delivery |
| **Stop Frame**  | 1 Bit | High-driven line topology confirming transaction close |

### 🔄 The Data Frame Flow
```text
  IDLE      START          DATA BITS (LSB -> MSB)          STOP      IDLE
 (Logic 1) ┌───┐ ┌───┬───┬───┬───┬───┬───┬───┬───┐       ┌───┐    (Logic 1)
 ──────────┘   └─┤ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 ├───────┘   └──────────────
                 └───┴───┴───┴───┴───┴───┴───┴───┘
```

---

## 🏗️ Hardware Module Directory

*   📂 **`rtl/uart_tx.v`**: The Transmitter engine. Translates a parallel byte into a continuous serial sequence using shift register arrays triggered by a `tx_start` flag.
*   📂 **`rtl/uart_rx.v`**: The Receiver engine. Identifies incoming falling edges (Start Bit), runs center-aligned bit validation, and outputs a clean parallel payload alongside an `rx_done` tick.
*   📂 **`rtl/uart_top.v`**: Structural network tying the serial-out of the transmitter directly into the serial-in of the receiver for total local verification.
*   📂 **`bench/uart_tb.v`**: Self-checking Testbench pipeline supplying asynchronous operational clock signals and diagnostic vectors.

---

## 🚦 Simulation Verification Workflow

This core was verified in simulation using testbench injection metrics executing deterministic transactions (`0xAB` and `0x55`).

### How to Run via Xilinx Vivado:
1. Open **Xilinx Vivado** and create a new project targeting your choice FPGA (e.g., Artix-7/Basys 3).
2. Import the source assets found inside the `/rtl` catalog into **Design Sources**.
3. Import `bench/uart_tb.v` into your **Simulation Sources**.
4. Right-click the testbench and select **Run Behavioral Simulation**.
5. Set your waveform tracker window scale to observe bit ticks across the baud execution windows.

### Expected Console Output Log:
```text
[TIME: 0] TB: Transmitting packet data 8'hAB...
[TB] Transmitter is now busy...
[SUCCESS] Verified. Matches: 8'hab
[TIME: 104200] TB: Transmitting checkerboard pattern 8'h55...
[SUCCESS] Verified. Matches: 8'h55
[SIMULATION] All transactions complete safely.
```

---

## 📜 License
This architecture is released completely open-source under the terms of the [MIT License](LICENSE).
