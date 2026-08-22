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

    // Tiny Tapeout pin mapping
    //
    // ui_in[7:0]  : Data / Search data
    //
    // uio_in[2:0] : Write address
    // uio_in[3]   : Write enable
    // uio_in[4]   : Load mask
    // uio_in[5]   : Search enable
    // uio_in[6]   : Unused
    // uio_in[7]   : Unused
    //
    // uo_out[0]   : Match
    // uo_out[3:1] : Match address
    // uo_out[7:4] : Unused

    wire [2:0] write_addr;
    wire       write_en;
    wire       load_mask;
    wire       search_en;

    assign write_addr = uio_in[2:0];
    assign write_en   = uio_in[3];
    assign load_mask  = uio_in[4];
    assign search_en  = uio_in[5];

    // Mask register
    reg [7:0] mask_reg = 8'h00;

    wire cam_rst;

    assign cam_rst = ~rst_n;

    always @(posedge clk) begin
        if (cam_rst) begin
            mask_reg <= 8'h00;
        end
        else if (load_mask) begin
            mask_reg <= ui_in;
        end
    end

    // CAM outputs
    wire       cam_match;
    wire [2:0] cam_match_addr;

    // CAM core
    configurable_cam #(
        .DATA_WIDTH (8),
        .DEPTH      (8),
        .ADDR_WIDTH (3)
    ) cam_core (
        .clk         (clk),
        .rst         (cam_rst),

        .write_en    (write_en),
        .write_addr  (write_addr),
        .write_data  (ui_in),

        .search_data (ui_in),
        .mask        (mask_reg),

        .match       (cam_match),
        .match_addr  (cam_match_addr)
    );

    // Output mapping
   // Output mapping
assign uo_out = {
    4'b0000,
    cam_match_addr[2],
    cam_match_addr[1],
    cam_match_addr[0],
    cam_match
};
    // Bidirectional pins used only as inputs
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Prevent unused-input warnings
    wire _unused = &{ena, uio_in[6], uio_in[7], 1'b0};

endmodule

`default_nettype wire
