`default_nettype none

module configurable_cam #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8,
    parameter ADDR_WIDTH = 3
)(
    input  wire                   clk,
    input  wire                   rst,

    // Write interface
    input  wire                   write_en,
    input  wire [ADDR_WIDTH-1:0]  write_addr,
    input  wire [DATA_WIDTH-1:0]  write_data,

    // Search interface
    input  wire [DATA_WIDTH-1:0]  search_data,
    input  wire [DATA_WIDTH-1:0]  mask,

    // Registered search result
    output reg                    match,
    output reg [ADDR_WIDTH-1:0]   match_addr
);

    // =========================================================
    // 8 CAM ENTRIES
    // =========================================================

    reg [DATA_WIDTH-1:0] cam_mem0;
    reg [DATA_WIDTH-1:0] cam_mem1;
    reg [DATA_WIDTH-1:0] cam_mem2;
    reg [DATA_WIDTH-1:0] cam_mem3;
    reg [DATA_WIDTH-1:0] cam_mem4;
    reg [DATA_WIDTH-1:0] cam_mem5;
    reg [DATA_WIDTH-1:0] cam_mem6;
    reg [DATA_WIDTH-1:0] cam_mem7;

    // =========================================================
    // COMBINATIONAL SEARCH RESULT
    // =========================================================

    reg                  match_comb;
    reg [ADDR_WIDTH-1:0] match_addr_comb;

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
        end
        else if (write_en) begin

            case (write_addr)

                3'd0: cam_mem0 <= write_data;
                3'd1: cam_mem1 <= write_data;
                3'd2: cam_mem2 <= write_data;
                3'd3: cam_mem3 <= write_data;
                3'd4: cam_mem4 <= write_data;
                3'd5: cam_mem5 <= write_data;
                3'd6: cam_mem6 <= write_data;
                3'd7: cam_mem7 <= write_data;

                default: begin
                    cam_mem0 <= cam_mem0;
                    cam_mem1 <= cam_mem1;
                    cam_mem2 <= cam_mem2;
                    cam_mem3 <= cam_mem3;
                    cam_mem4 <= cam_mem4;
                    cam_mem5 <= cam_mem5;
                    cam_mem6 <= cam_mem6;
                    cam_mem7 <= cam_mem7;
                end

            endcase
        end
    end

    // =========================================================
    // COMBINATIONAL CAM SEARCH
    //
    // mask bit = 0 : compare
    // mask bit = 1 : ignore
    //
    // Lowest address gets priority.
    // =========================================================

    always @(*) begin

        match_comb      = 1'b0;
        match_addr_comb = 3'b000;

        // Address 0
        if (!match_comb &&
            (((cam_mem0 ^ search_data) & ~mask) == 8'h00)) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd0;
        end

        // Address 1
        if (!match_comb &&
            (((cam_mem1 ^ search_data) & ~mask) == 8'h00)) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd1;
        end

        // Address 2
        if (!match_comb &&
            (((cam_mem2 ^ search_data) & ~mask) == 8'h00)) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd2;
        end

        // Address 3
        if (!match_comb &&
            (((cam_mem3 ^ search_data) & ~mask) == 8'h00)) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd3;
        end

        // Address 4
        if (!match_comb &&
            (((cam_mem4 ^ search_data) & ~mask) == 8'h00)) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd4;
        end

        // Address 5
        if (!match_comb &&
            (((cam_mem5 ^ search_data) & ~mask) == 8'h00)) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd5;
        end

        // Address 6
        if (!match_comb &&
            (((cam_mem6 ^ search_data) & ~mask) == 8'h00)) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd6;
        end

        // Address 7
        if (!match_comb &&
            (((cam_mem7 ^ search_data) & ~mask) == 8'h00)) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd7;
        end
    end

    // =========================================================
    // ONE-CLOCK SEARCH
    //
    // Search result is captured on ONE rising edge.
    // =========================================================

    always @(posedge clk) begin
        if (rst) begin
            match      <= 1'b0;
            match_addr <= 3'b000;
        end
        else begin
            match      <= match_comb;
            match_addr <= match_addr_comb;
        end
    end

endmodule

`default_nettype wire
