`default_nettype none

`timescale 1ns / 1ps

module tb;

    // =========================================================
    // Tiny Tapeout signals
    // =========================================================

    reg         clk;
    reg         rst_n;
    reg         ena;

    reg  [7:0]  ui_in;
    wire [7:0]  uo_out;

    reg  [7:0]  uio_in;
    wire [7:0]  uio_out;
    wire [7:0]  uio_oe;

    // =========================================================
    // Gate-level power pins
    //
    // VPWR and VGND are INOUT ports in the gate-level netlist.
    // Therefore they must be connected to wires and driven
    // using continuous assignments.
    // =========================================================

    wire VPWR;
    wire VGND;

    assign VPWR = 1'b1;
    assign VGND = 1'b0;

    // =========================================================
    // DUT
    // =========================================================

    tt_um_vaishnavipatil5_configurable_cam user_project (
        .ui_in   (ui_in),
        .uo_out  (uo_out),

        .uio_in  (uio_in),
        .uio_out (uio_out),
        .uio_oe  (uio_oe),

        .ena     (ena),
        .clk     (clk),
        .rst_n   (rst_n)

`ifdef GL_TEST
        ,
        .VPWR    (VPWR),
        .VGND    (VGND)
`endif
    );

    // =========================================================
    // Waveform dump
    // =========================================================

    initial begin
        $dumpfile("tb.fst");
        $dumpvars(0, tb);
    end

endmodule

`default_nettype wire
