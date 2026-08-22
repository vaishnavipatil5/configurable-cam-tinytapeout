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

    reg [DATA_WIDTH-1:0] cam_mem [0:DEPTH-1];
    reg [DEPTH-1:0] valid;

    reg match_comb;
    reg [ADDR_WIDTH-1:0] match_addr_comb;

    integer i;
    integer j;

    // =====================================================
    // CAM WRITE AND RESET
    // =====================================================

    always @(posedge clk) begin
        if (rst) begin

            valid <= {DEPTH{1'b0}};

            for (i = 0; i < DEPTH; i = i + 1) begin
                cam_mem[i] <= {DATA_WIDTH{1'b0}};
            end

        end
        else if (write_en) begin

            cam_mem[write_addr] <= write_data;
            valid[write_addr] <= 1'b1;

        end
    end

    // =====================================================
    // COMBINATIONAL SEARCH
    // =====================================================

    always @(*) begin

        match_comb = 1'b0;
        match_addr_comb = {ADDR_WIDTH{1'b0}};

        for (j = 0; j < DEPTH; j = j + 1) begin

            if (valid[j] == 1'b1) begin

                if (((cam_mem[j] ^ search_data) & ~mask) == {DATA_WIDTH{1'b0}}) begin

                    if (match_comb == 1'b0) begin
                        match_comb = 1'b1;
                        match_addr_comb = j[ADDR_WIDTH-1:0];
                    end

                end

            end

        end

    end

    // =====================================================
    // REGISTERED OUTPUT
    // ONE CLOCK EDGE
    // =====================================================

    always @(posedge clk) begin

        if (rst) begin

            match <= 1'b0;
            match_addr <= {ADDR_WIDTH{1'b0}};

        end
        else begin

            match <= match_comb;
            match_addr <= match_addr_comb;

        end

    end

endmodule
