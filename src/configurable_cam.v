`default_nettype none

module configurable_cam #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8,
    parameter ADDR_WIDTH = 3
)(
    input  wire                    clk,
    input  wire                    rst,

    // Write interface
    input  wire                    write_en,
    input  wire [ADDR_WIDTH-1:0]   write_addr,
    input  wire [DATA_WIDTH-1:0]   write_data,

    // Search interface
    input  wire [DATA_WIDTH-1:0]   search_data,
    input  wire [DATA_WIDTH-1:0]   mask,

    // Search result
    output reg                     match,
    output reg [ADDR_WIDTH-1:0]    match_addr
);

    // =========================================================
    // CAM STORAGE
    // =========================================================

    reg [DATA_WIDTH-1:0] cam_mem [0:DEPTH-1];

    integer i;
    integer j;

    // =========================================================
    // WRITE / RESET
    // =========================================================

    always @(posedge clk) begin

        if (rst) begin

            for (i = 0; i < DEPTH; i = i + 1) begin
                cam_mem[i] <= {DATA_WIDTH{1'b0}};
            end

        end
        else if (write_en) begin

            cam_mem[write_addr] <= write_data;
        end

    end

    // =========================================================
    // SYNCHRONOUS ONE-CLOCK SEARCH
    //
    // mask = 1 -> ignore that bit
    // mask = 0 -> compare that bit
    //
    // First matching address gets priority.
    // =========================================================

    always @(posedge clk) begin

        if (rst) begin

            match      <= 1'b0;
            match_addr <= {ADDR_WIDTH{1'b0}};

        end
        else begin

            // Default result: no match
            match      <= 1'b0;
            match_addr <= {ADDR_WIDTH{1'b0}};

            // Search all CAM entries
            for (j = 0; j < DEPTH; j = j + 1) begin

                if (((cam_mem[j] ^ search_data) & ~mask) ==
                    {DATA_WIDTH{1'b0}}) begin

                    // First matching entry gets priority
                    if (match == 1'b0) begin
                        match      <= 1'b1;
                        match_addr <= j[ADDR_WIDTH-1:0];
                    end

                end

            end

        end

    end

endmodule

`default_nettype wire
