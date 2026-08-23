# 8-bit Configurable CAM with Masked Search and Priority Matching

## How it works

This project implements an 8-bit configurable Content-Addressable Memory (CAM) for Tiny Tapeout SKY26C.

The CAM stores 8-bit data words in multiple memory locations and allows the stored contents to be searched in parallel using an input search value.

The design supports three main operations:

- Write data to a selected CAM address
- Search for an exact data match
- Search using a masked value

During a search operation, the input search value is compared against the stored CAM entries. If an exact match is found, the corresponding address is reported.

The CAM also supports masked matching, where selected bits of the search value can be ignored during comparison. This allows partially specified search patterns to be matched against stored data.

When multiple CAM entries match the same search value, a priority matching mechanism selects the lowest matching address as the result.

The main blocks are:

- 8-bit CAM memory array
- Parallel comparison logic
- Masked comparison logic
- Address decoding
- Priority encoder
- Search and write control logic
- Match detection and output logic

The design is intended to provide compact and configurable content-addressable searching suitable for small digital lookup and pattern-matching applications.

## How to test

1. Apply reset by driving `rst_n` low.
2. Release reset by driving `rst_n` high.
3. Enable the design using the appropriate enable signal.
4. Perform a write operation by providing an 8-bit data value and selecting the required CAM address.
5. Perform a search operation by providing the required 8-bit search value.
6. Verify that an exact match produces the corresponding stored address.
7. Verify that a search value with no matching entry produces a no-match result.
8. Apply a mask and verify that the masked bits are ignored during comparison.
9. Write the same data value to multiple CAM addresses.
10. Perform a priority search and verify that the lowest matching address is returned.
11. Verify that the CAM produces the expected result within the required clock cycle.

The Cocotb testbench in `test/test.py` performs functional verification of the CAM, including write operations, exact-match searches, no-match searches, masked matching, and priority matching.

The gate-level test verifies the hardened design and confirms that the CAM functionality is preserved after synthesis and physical implementation.

## Verification

The design has been successfully verified through the Tiny Tapeout SKY26C flow.

- Precheck: PASS
- Gate-level test: PASS
- DRC: PASS with 0 errors
- LVS: PASS
- GDS generation: PASS

The gate-level verification includes:

- Exact match verification
- No-match verification
- Masked match verification
- Priority match verification

## Credits

We gratefully acknowledge the Center of Excellence (CoE) in Integrated Circuits and Systems (ICAS) and the Department of Electronics and Communication Engineering (ECE) for providing the necessary resources and guidance.

Special thanks to Dr. H V Ravish Aradhya (HoD- ECE), Dr. K R Usha Rani (Associate Dean-PG), Dr. K. S. Geetha (Vice Principal) and Dr. K. N. Subramanya (Principal) for their constant encouragement and support in facilitating this Tiny Tapeout SKY26C submission.
