`default_nettype none

module tt_um_vaishnavipatil5_configurable_cam (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    // =========================================================
    // Tiny Tapeout pin mapping
    // =========================================================
    //
    // ui_in[7:0]  : Data bus
    //
    // uio_in[2:0] : Write address
    // uio_in[3]   : Write enable
    // uio_in[4]   : Load mask
    // uio_in[5]   : Search enable
    // uio_in[6]   : unused
    // uio_in[7]   : unused
    //
    // uo_out[0]   : Match
    // uo_out[3:1] : Match address
    // uo_out[7:4] : unused
    //
    // =========================================================

    wire [2:0] write_addr;
    wire       write_en;
    wire       load_mask;
    wire       search_en;

    assign write_addr = uio_in[2:0];
    assign write_en   = uio_in[3];
    assign load_mask  = uio_in[4];
    assign search_en  = uio_in[5];

    // =========================================================
    // Mask register
    //
    // Mask is loaded before the search operation.
    // During the actual SEARCH clock, ui_in is the search data.
    // =========================================================

    reg [7:0] mask_reg;

    wire cam_rst;

    // Tiny Tapeout reset is active LOW.
    // CAM core reset is active HIGH.
    assign cam_rst = ~rst_n;

    always @(posedge clk) begin
        if (cam_rst) begin
            mask_reg <= 8'h00;
        end
        else if (load_mask) begin
            mask_reg <= ui_in;
        end
    end

    // =========================================================
    // CAM outputs
    // =========================================================

    wire       cam_match;
    wire [2:0] cam_match_addr;

    // =========================================================
    // CAM CORE
    //
    // IMPORTANT:
    // ui_in goes DIRECTLY to search_data.
    //
    // Therefore:
    //
    // Before rising edge:
    //     ui_in      = search data
    //     search_en  = 1
    //
    // At ONE rising edge:
    //     CAM performs search
    //     match and match_addr are registered
    //
    // Immediately after that edge:
    //     cam_match
    //     cam_match_addr
    //
    // contain the result.
    // =========================================================

    configurable_cam #(
        .DATA_WIDTH (8),
        .DEPTH      (8),
        .ADDR_WIDTH (3)
    ) cam_core (
        .clk        (clk),
        .rst        (cam_rst),

        .write_en   (write_en),
        .write_addr (write_addr),
        .write_data (ui_in),

        .search_data(ui_in),
        .mask       (mask_reg),

        .match      (cam_match),
        .match_addr (cam_match_addr)
    );

    // =========================================================
    // OUTPUT MAPPING
    // =========================================================

    assign uo_out[0] = search_en ? cam_match : 1'b0;

    assign uo_out[1] = search_en ? cam_match_addr[0] : 1'b0;
    assign uo_out[2] = search_en ? cam_match_addr[1] : 1'b0;
    assign uo_out[3] = search_en ? cam_match_addr[2] : 1'b0;

    assign uo_out[7:4] = 4'b0000;

    // Bidirectional pins are used only as inputs.
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Prevent unused-input warnings.
    wire _unused = &{ena, uio_in[6], uio_in[7], 1'b0};

endmodule

`default_nettype wire
