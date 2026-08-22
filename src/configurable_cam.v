module configurable_cam #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8,
    parameter ADDR_WIDTH = 3
)(
    input  wire                     clk,
    input  wire                     rst,

    // Write interface
    input  wire                     write_en,
    input  wire [ADDR_WIDTH-1:0]    write_addr,
    input  wire [DATA_WIDTH-1:0]    write_data,

    // Search interface
    input  wire [DATA_WIDTH-1:0]    search_data,
    input  wire [DATA_WIDTH-1:0]    mask,

    // Search result
    output reg                      match,
    output reg [ADDR_WIDTH-1:0]     match_addr
);

    // =====================================================
    // CAM STORAGE
    // =====================================================

    reg [DATA_WIDTH-1:0] cam_mem [0:DEPTH-1];

    integer i;
    integer j;

    // =====================================================
    // INTERNAL SEARCH RESULTS
    // =====================================================

    reg                   match_comb;
    reg [ADDR_WIDTH-1:0]  match_addr_comb;

    // =====================================================
    // WRITE / RESET OPERATION
    // =====================================================

   always @(posedge clk) begin
    if (rst) begin
        cam_mem[0] <= {DATA_WIDTH{1'b0}};
        cam_mem[1] <= {DATA_WIDTH{1'b0}};
        cam_mem[2] <= {DATA_WIDTH{1'b0}};
        cam_mem[3] <= {DATA_WIDTH{1'b0}};
        cam_mem[4] <= {DATA_WIDTH{1'b0}};
        cam_mem[5] <= {DATA_WIDTH{1'b0}};
        cam_mem[6] <= {DATA_WIDTH{1'b0}};
        cam_mem[7] <= {DATA_WIDTH{1'b0}};
    end
    else if (write_en) begin
        cam_mem[write_addr] <= write_data;
    end
end
    // =====================================================
    // PARALLEL SEARCH + MASKING + PRIORITY
    // =====================================================

    always @(*) begin

        match_comb      = 1'b0;
        match_addr_comb = {ADDR_WIDTH{1'b0}};

        for (j = 0; j < DEPTH; j = j + 1) begin

            /*
             * Mask = 1 means ignore that bit.
             *
             * Only accept a definite equality.
             * This prevents X from becoming a valid match.
             */
            if (((cam_mem[j] ^ search_data) & ~mask) == {DATA_WIDTH{1'b0}}) begin

                if (match_comb == 1'b0) begin
                    match_comb      = 1'b1;
                    match_addr_comb = j;
                end

            end

        end
    end

    // =====================================================
    // REGISTERED OUTPUT
    // =====================================================

    always @(posedge clk) begin
        if (rst) begin
            match      <= 1'b0;
            match_addr <= {ADDR_WIDTH{1'b0}};
        end
        else begin
            match      <= match_comb;
            match_addr <= match_addr_comb;
        end
    end

endmodule
