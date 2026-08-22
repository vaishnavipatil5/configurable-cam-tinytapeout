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
    // EXPLICIT CAM STORAGE
    // =====================================================

    reg [DATA_WIDTH-1:0] cam_mem0;
    reg [DATA_WIDTH-1:0] cam_mem1;
    reg [DATA_WIDTH-1:0] cam_mem2;
    reg [DATA_WIDTH-1:0] cam_mem3;
    reg [DATA_WIDTH-1:0] cam_mem4;
    reg [DATA_WIDTH-1:0] cam_mem5;
    reg [DATA_WIDTH-1:0] cam_mem6;
    reg [DATA_WIDTH-1:0] cam_mem7;

    // =====================================================
    // WRITE OPERATION
    // =====================================================

    always @(posedge clk) begin

        if (rst) begin

            cam_mem0 <= {DATA_WIDTH{1'b0}};
            cam_mem1 <= {DATA_WIDTH{1'b0}};
            cam_mem2 <= {DATA_WIDTH{1'b0}};
            cam_mem3 <= {DATA_WIDTH{1'b0}};
            cam_mem4 <= {DATA_WIDTH{1'b0}};
            cam_mem5 <= {DATA_WIDTH{1'b0}};
            cam_mem6 <= {DATA_WIDTH{1'b0}};
            cam_mem7 <= {DATA_WIDTH{1'b0}};

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
                end

            endcase

        end

    end

    // =====================================================
    // PARALLEL SEARCH + MASKING + PRIORITY
    // =====================================================

    reg                    match_comb;
    reg [ADDR_WIDTH-1:0]   match_addr_comb;

    always @(*) begin

        match_comb      = 1'b0;
        match_addr_comb = {ADDR_WIDTH{1'b0}};

        // Address 0 has highest priority
        if (((cam_mem0 ^ search_data) & ~mask) == 0) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd0;
        end

        else if (((cam_mem1 ^ search_data) & ~mask) == 0) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd1;
        end

        else if (((cam_mem2 ^ search_data) & ~mask) == 0) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd2;
        end

        else if (((cam_mem3 ^ search_data) & ~mask) == 0) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd3;
        end

        else if (((cam_mem4 ^ search_data) & ~mask) == 0) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd4;
        end

        else if (((cam_mem5 ^ search_data) & ~mask) == 0) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd5;
        end

        else if (((cam_mem6 ^ search_data) & ~mask) == 0) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd6;
        end

        else if (((cam_mem7 ^ search_data) & ~mask) == 0) begin
            match_comb      = 1'b1;
            match_addr_comb = 3'd7;
        end

    end

    // =====================================================
    // REGISTERED SEARCH RESULT
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
