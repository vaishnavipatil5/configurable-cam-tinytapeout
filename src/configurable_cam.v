`default_nettype none

module configurable_cam #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8,
    parameter ADDR_WIDTH = 3
)(
    input  wire                  clk,
    input  wire                  rst,

    input  wire                  write_en,
    input  wire [ADDR_WIDTH-1:0] write_addr,
    input  wire [DATA_WIDTH-1:0] write_data,

    input  wire [DATA_WIDTH-1:0] search_data,
    input  wire [DATA_WIDTH-1:0] mask,

    output reg                   match,
    output reg [ADDR_WIDTH-1:0]  match_addr
);

    // =========================================================
    // CAM STORAGE
    // =========================================================

    reg [7:0] cam_mem0;
    reg [7:0] cam_mem1;
    reg [7:0] cam_mem2;
    reg [7:0] cam_mem3;
    reg [7:0] cam_mem4;
    reg [7:0] cam_mem5;
    reg [7:0] cam_mem6;
    reg [7:0] cam_mem7;

    // Valid bits
    reg valid0;
    reg valid1;
    reg valid2;
    reg valid3;
    reg valid4;
    reg valid5;
    reg valid6;
    reg valid7;

    // =========================================================
    // WRITE + RESET
    // =========================================================

    always @(posedge clk) begin

        if (rst) begin

            cam_mem0 <= 8'h00;
            cam_mem1 <= 8'h00;
            cam_mem2 <= 8'h00;
            cam_mem3 <= 8'h00;
            cam_mem4 <= 8'h00;
            cam_mem5 <= 8'h00;
            cam_mem6 <= 8'h00;
            cam_mem7 <= 8'h00;

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
                    cam_mem0 <= write_data;
                    valid0   <= 1'b1;
                end

                3'd1: begin
                    cam_mem1 <= write_data;
                    valid1   <= 1'b1;
                end

                3'd2: begin
                    cam_mem2 <= write_data;
                    valid2   <= 1'b1;
                end

                3'd3: begin
                    cam_mem3 <= write_data;
                    valid3   <= 1'b1;
                end

                3'd4: begin
                    cam_mem4 <= write_data;
                    valid4   <= 1'b1;
                end

                3'd5: begin
                    cam_mem5 <= write_data;
                    valid5   <= 1'b1;
                end

                3'd6: begin
                    cam_mem6 <= write_data;
                    valid6   <= 1'b1;
                end

                3'd7: begin
                    cam_mem7 <= write_data;
                    valid7   <= 1'b1;
                end

                default: begin
                end

            endcase
        end
    end

    // =========================================================
    // COMBINATIONAL SEARCH
    //
    // mask = 0 -> compare
    // mask = 1 -> ignore
    //
    // Lowest address has priority.
    // =========================================================

    reg search_match;
    reg [2:0] search_addr;

    always @(*) begin

        search_match = 1'b0;
        search_addr  = 3'b000;

        if (valid0 &&
            (((cam_mem0 ^ search_data) & ~mask) == 8'h00)) begin

            search_match = 1'b1;
            search_addr  = 3'd0;

        end
        else if (valid1 &&
                 (((cam_mem1 ^ search_data) & ~mask) == 8'h00)) begin

            search_match = 1'b1;
            search_addr  = 3'd1;

        end
        else if (valid2 &&
                 (((cam_mem2 ^ search_data) & ~mask) == 8'h00)) begin

            search_match = 1'b1;
            search_addr  = 3'd2;

        end
        else if (valid3 &&
                 (((cam_mem3 ^ search_data) & ~mask) == 8'h00)) begin

            search_match = 1'b1;
            search_addr  = 3'd3;

        end
        else if (valid4 &&
                 (((cam_mem4 ^ search_data) & ~mask) == 8'h00)) begin

            search_match = 1'b1;
            search_addr  = 3'd4;

        end
        else if (valid5 &&
                 (((cam_mem5 ^ search_data) & ~mask) == 8'h00)) begin

            search_match = 1'b1;
            search_addr  = 3'd5;

        end
        else if (valid6 &&
                 (((cam_mem6 ^ search_data) & ~mask) == 8'h00)) begin

            search_match = 1'b1;
            search_addr  = 3'd6;

        end
        else if (valid7 &&
                 (((cam_mem7 ^ search_data) & ~mask) == 8'h00)) begin

            search_match = 1'b1;
            search_addr  = 3'd7;

        end
    end

    // =========================================================
    // REGISTER SEARCH RESULT
    //
    // ONE rising edge only.
    // =========================================================

    always @(posedge clk) begin

        if (rst) begin

            match      <= 1'b0;
            match_addr <= 3'b000;

        end
        else begin

            match      <= search_match;
            match_addr <= search_addr;

        end
    end

endmodule

`default_nettype wire
