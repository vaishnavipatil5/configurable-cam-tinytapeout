module configurable_cam #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8,
    parameter ADDR_WIDTH = 3
)(
    input wire clk,
    input wire rst,

    input wire write_en,
    input wire [ADDR_WIDTH-1:0] write_addr,
    input wire [DATA_WIDTH-1:0] write_data,

    input wire [DATA_WIDTH-1:0] search_data,
    input wire [DATA_WIDTH-1:0] mask,

    output reg match,
    output reg [ADDR_WIDTH-1:0] match_addr
);

    // =====================================================
    // EXPLICIT CAM STORAGE
    // =====================================================

    reg [7:0] mem0;
    reg [7:0] mem1;
    reg [7:0] mem2;
    reg [7:0] mem3;
    reg [7:0] mem4;
    reg [7:0] mem5;
    reg [7:0] mem6;
    reg [7:0] mem7;

    reg valid0;
    reg valid1;
    reg valid2;
    reg valid3;
    reg valid4;
    reg valid5;
    reg valid6;
    reg valid7;

    reg match_comb;
    reg [2:0] match_addr_comb;

    // =====================================================
    // WRITE + RESET
    // =====================================================

    always @(posedge clk) begin

        if (rst) begin

            mem0 <= 8'h00;
            mem1 <= 8'h00;
            mem2 <= 8'h00;
            mem3 <= 8'h00;
            mem4 <= 8'h00;
            mem5 <= 8'h00;
            mem6 <= 8'h00;
            mem7 <= 8'h00;

            valid0 <= 1'b0;
            valid1 <= 1'b0;
            valid2 <= 1'b0;
            valid3 <= 1'b0;
            valid4 <= 1'b0;
            valid5 <= 1'b0;
            valid6 <= 1'b0;
            valid7 <= 1'b0;

        end
        else if (write_en) begin

            case (write_addr)

                3'd0: begin
                    mem0 <= write_data;
                    valid0 <= 1'b1;
                end

                3'd1: begin
                    mem1 <= write_data;
                    valid1 <= 1'b1;
                end

                3'd2: begin
                    mem2 <= write_data;
                    valid2 <= 1'b1;
                end

                3'd3: begin
                    mem3 <= write_data;
                    valid3 <= 1'b1;
                end

                3'd4: begin
                    mem4 <= write_data;
                    valid4 <= 1'b1;
                end

                3'd5: begin
                    mem5 <= write_data;
                    valid5 <= 1'b1;
                end

                3'd6: begin
                    mem6 <= write_data;
                    valid6 <= 1'b1;
                end

                3'd7: begin
                    mem7 <= write_data;
                    valid7 <= 1'b1;
                end

                default: begin
                end

            endcase

        end

    end

    // =====================================================
    // SEARCH
    // First matching address gets priority
    //
    // mask = 1 -> ignore that bit
    // =====================================================

    always @(*) begin

        match_comb = 1'b0;
        match_addr_comb = 3'b000;

        if (valid0 &&
            (((mem0 ^ search_data) & ~mask) == 8'h00)) begin

            match_comb = 1'b1;
            match_addr_comb = 3'd0;

        end
        else if (valid1 &&
                 (((mem1 ^ search_data) & ~mask) == 8'h00)) begin

            match_comb = 1'b1;
            match_addr_comb = 3'd1;

        end
        else if (valid2 &&
                 (((mem2 ^ search_data) & ~mask) == 8'h00)) begin

            match_comb = 1'b1;
            match_addr_comb = 3'd2;

        end
        else if (valid3 &&
                 (((mem3 ^ search_data) & ~mask) == 8'h00)) begin

            match_comb = 1'b1;
            match_addr_comb = 3'd3;

        end
        else if (valid4 &&
                 (((mem4 ^ search_data) & ~mask) == 8'h00)) begin

            match_comb = 1'b1;
            match_addr_comb = 3'd4;

        end
        else if (valid5 &&
                 (((mem5 ^ search_data) & ~mask) == 8'h00)) begin

            match_comb = 1'b1;
            match_addr_comb = 3'd5;

        end
        else if (valid6 &&
                 (((mem6 ^ search_data) & ~mask) == 8'h00)) begin

            match_comb = 1'b1;
            match_addr_comb = 3'd6;

        end
        else if (valid7 &&
                 (((mem7 ^ search_data) & ~mask) == 8'h00)) begin

            match_comb = 1'b1;
            match_addr_comb = 3'd7;

        end

    end

    // =====================================================
    // REGISTERED OUTPUT
    // ONE CLOCK EDGE
    // =====================================================

    always @(posedge clk) begin

        if (rst) begin

            match <= 1'b0;
            match_addr <= 3'b000;

        end
        else begin

            match <= match_comb;
            match_addr <= match_addr_comb;

        end

    end

endmodule
