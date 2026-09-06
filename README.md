
# Verilog UART Project (TX & RX Modules)

A simple and clean implementation of the **UART (Universal Asynchronous Receiver-Transmitter)** protocol written in **Verilog HDL**. 

This project contains independent Transmitter (TX) and Receiver (RX) modules connected together in a top-level wrapper for easy testing.

---

## Features
* **Full UART Core:** Includes both transmitter (`uart_tx`) and receiver (`uart_rx`) logic.
* **FSM-Based Design:** Uses structured Finite State Machines to reliably manage data transmission and reception cycles.
* **Loopback Test Top Module:** Connects the TX output line directly back to the RX input line so you can test sending and receiving data simultaneously.

---

## Project Structure

* **`uart_tx.v`** - Converts parallel 8-bit input data into a serial stream of bits.
* **`uart_rx.v`** - Receives serial data bits and converts them back into an 8-bit parallel byte.
* **`uart_top.v`** - The top-level design that wires the TX module and RX module together.


---

## UART Frame Format (8-N-1)

The system communicates asynchronously using a standard **8-N-1** frame structure (1 Start Bit, 8 Data Bits, No Parity Bit, 1 Stop Bit). The communication line sits at **Logic 1 (High)** when idle. 

### Visual Timing Frame:
```text
  IDLE      START          DATA BITS (LSB -> MSB)          STOP      IDLE
 (Logic 1) ┌───┐ ┌───┬───┬───┬───┬───┬───┬───┬───┐       ┌───┐    (Logic 1)
 ──────────┘   └─┤ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 ├───────┘   └──────────────
                 └───┴───┴───┴───┴───┴───┴───┴───┘
```

### Frame Breakdown:
* **Idle State:** The line is held High (`1`) when no data is being sent.
* **Start Bit:** The transmitter pulls the line Low (`0`) for 1 bit-period to signal that a packet is starting.
* **Data Bits:** 8 bits of data are sent sequentially, starting with the **Least Significant Bit (LSB)** first.
* **Parity Bit:** None (`N`). Error-checking is omitted to maximize throughput.
* **Stop Bit:** The transmitter drives the line back High (`1`) for 1 bit-period to signal the end of the data frame.

---
## Protocol & Frame Specifications

| Parameter | Configuration Specification | Purpose / Notes |
| :--- | :--- | :--- |
| **Baud Rate** | Configurable (Default: 9600) | Synchronized via parameterized hardware counter |
| **Data Payload**| 8 Bits | Sent Least Significant Bit (LSB) first |
| **Parity Bit**  | None (`N`) | Optimized for high-throughput, raw payload delivery |
| **Stop Frame**  | 1 Bit | High-driven line topology confirming transaction close |

---
## Finite State Machine (FSM) States

*   **`IDLE`**: The default state. The logic waits for transmission/reception to begin 
*   **`START`**: Implements the starting frame. The transmitter drives the line low, while the receiver confirms the validity of the incoming low start bit.
*   **`DATA`**: Processes the 8-bit payload. A bit-counter tracks progress while internal shift registers sequentially transmit or collect data bits at the calculated baud rate interval.
*   **`STOP`**: Finalizes the data frame. The transmitter drives the line high to close the packet, and the receiver checks for a valid high stop bit before outputting the recovered byte.

