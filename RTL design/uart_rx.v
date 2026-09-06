module uart_receiver(
    input clk,
    input rst,
    input rx,
    output reg [7:0] data_rx
);
    localparam IDLE      = 2'b00;
    localparam RECEIVING = 2'b01;
    localparam STOP      = 2'b10;

    reg [1:0] state;
    localparam baud_count = 100000000 / 9600;
    reg [31:0] baud_tik;
    reg [3:0] bit_count;
    reg [9:0] shift_reg;
    reg sample_bit=0;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            bit_count<= 0;
            shift_reg<= 0;
            state<= IDLE;
            baud_tik<= 0;
            sample_bit<= 0;
        end else begin
            case (state)
                IDLE: begin
                    baud_tik <= 0;
                    bit_count <= 0;
                    shift_reg <= 0;
                    if (rx ==0) begin
                        state <= RECEIVING;
                    end else begin
                        state <= IDLE;
                    end
                end

                RECEIVING: begin
                    if (baud_tik == (baud_count/ 2)) begin
                        sample_bit <= rx;
                    end
                    if (baud_tik == (baud_count - 1)) begin
                        shift_reg <= {sample_bit, shift_reg[9:1]};
                         bit_count <= bit_count + 1;
                         baud_tik<=0;
                             if (bit_count == 9) begin
                               state     <= STOP;
                             end 
                           end 
                        else baud_tik <= baud_tik+1;
                    end

                STOP: begin
                    data_rx <= shift_reg[8:1]; 
                    bit_count <= 0;
                    state<= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
