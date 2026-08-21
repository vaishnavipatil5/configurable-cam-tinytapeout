# Configurable CAM

## How it works

The design implements an 8-entry, 8-bit configurable Content Addressable Memory (CAM).

Each CAM entry stores an 8-bit data value. During a write operation, the input data is stored at the selected address.

During a search operation, the input search data is compared with all stored entries simultaneously.

The CAM supports exact matching and masked matching. The mask allows selected bits of the search pattern to be ignored.

When multiple entries match the search data, priority resolution selects the lowest matching address.

The search result is registered on a single rising clock edge. The output indicates whether a match occurred and provides the address of the highest-priority matching entry.

## How to test

The design can be tested using the cocotb testbench in the `test` directory.

The testbench first resets the CAM and writes several data values into different addresses.

It then performs exact-match searches, a no-match search, a masked search, and a priority-resolution test.

Each CAM search operation is performed on exactly one rising clock edge.

The expected match status and match address are checked automatically by the cocotb testbench.

## Pin description

The `ui_in[7:0]` pins provide the 8-bit data input.

The `uio_in[2:0]` pins select the CAM write address.

`uio_in[3]` is the write-enable signal.

`uio_in[4]` loads the search mask.

`uio_in[5]` enables the search operation.

`uo_out[0]` indicates whether a match occurred.

`uo_out[3:1]` provide the matching CAM address.
