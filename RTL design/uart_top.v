module uart_top(
    input  clk,
    input rst,
    input  load,
    input  [7:0] data_tx,
    output [7:0] data_rx
);
    wire tx_rx_wire;
    uart_transmitter trans (clk,rst,load,data_tx,tx_rx_wire);
    uart_receiver rece (clk,rst,tx_rx_wire,data_rx);
endmodule
