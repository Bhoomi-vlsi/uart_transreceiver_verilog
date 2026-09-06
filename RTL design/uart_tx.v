module uart_transmitter(
    input clk,        
    input rst_n,        
    input load,
    input [7:0] data_tx,
    output reg tx            
);

    localparam IDLE     = 2'b00;
    localparam LOAD  = 2'b01;
    localparam TRANSMIT = 2'b10;
    localparam STOP     = 2'b11;
    reg [1:0] state;
    reg [9:0] shift_reg;    
    reg [3:0] bit_count;   
    reg [15:0] baud_tik;    

    parameter baud_count = 100000000 / 9600;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx         <= 1; 
            bit_count  <= 0;
            shift_reg  <= 0;
            baud_tik  <= 0;
            state      <= IDLE;
        end else begin
            case (state)
                
                IDLE: begin
                    tx<= 1; 
                    baud_tik <= 0;
                    bit_count <= 0;
                    
                    if (load) begin
                        state <= LOAD;
                    end else begin
                        state <= IDLE;
                    end
                end

                LOAD: begin
                    shift_reg <= {1'b1,data_tx,1'b0};
                    state<= TRANSMIT;
                end

                TRANSMIT: begin
                    if ((baud_tik == baud_count)&&(bit_count<=9)) begin
                    tx <= shift_reg[0]; 
                        shift_reg <= shift_reg >> 1;
                        bit_count <= bit_count + 1;
                        baud_tik<=0;
                        if (bit_count ==9) begin
                            bit_count <=0;
                            state<= STOP;
                        end 
                        end else 
                        baud_tik <= baud_tik + 1;
                    end

                STOP: begin
                    tx<=1; 
                    state<=IDLE; 
                end

                default:state <= IDLE;
            endcase
        end
    end

endmodule
