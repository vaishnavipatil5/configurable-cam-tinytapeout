# Configurable CAM with Masked Pattern Matching and Priority Resolution

**Tiny Tapeout submission, SKY130 130nm, TTSKY26C shuttle**

- [Read the full project documentation](docs/info.md)
- [View the project repository](https://github.com/vaishnavipatil5/configurable-cam-tinytapeout)

## What is this?

This project implements a compact **8-bit configurable Content-Addressable Memory (CAM)** with masked pattern matching and priority resolution.

Unlike conventional memory, where stored data is accessed using an address, a CAM searches its stored contents using an input search pattern. The design compares the search value against the stored CAM entries and returns the address of a matching entry.

The CAM supports exact pattern matching and masked pattern matching. When multiple entries match the search pattern, the lowest matching address is selected as the priority result.

The complete design was implemented through the **Tiny Tapeout SKY130 digital ASIC flow**, generating a final GDSII layout suitable for submission.

## Design summary

- **Architecture:** 8-bit configurable CAM
- **Function:** Content-addressable data searching
- **Storage:** 8 entries
- **Data width:** 8 bits
- **Matching:** Exact and masked pattern matching
- **Mask:** 8-bit configurable mask
- **Priority:** Lowest matching address
- **Search:** One-clock search operation
- **HDL:** Verilog
- **Technology:** SKY130 130nm
- **Target:** Tiny Tapeout SKY26C
- **Top module:** `tt_um_vaishnavipatil5_configurable_cam`
- **Implementation:** RTL-to-GDSII
- **Physical verification:** DRC and LVS passed
- **DRC result:** 0 violations
- **LVS result:** Circuits match uniquely

## How does it work?

The CAM stores 8-bit data values at eight different addresses.

During a write operation, an 8-bit data value is stored at the selected CAM address.

During a search operation, the input search value is compared with all stored CAM entries.

The mask controls which bits participate in the comparison. A mask bit of `0` means that the corresponding bit is compared, while a mask bit of `1` means that the corresponding bit is ignored.

If a matching entry is found, the CAM generates a match indication and provides the corresponding address.

When multiple entries match the search pattern, the lowest matching address is selected as the priority result. The search result is registered on one rising clock edge.

Thus, the overall architecture combines:

**CAM Storage + Parallel Comparison + Masked Pattern Matching + Match Detection + Priority Resolution**

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that makes it easier and more affordable to manufacture small digital and analog designs on real silicon.

To learn more, visit:

https://tinytapeout.com/

## Project Team

This project was executed by:

Vaishnavi Patil, Nishaanth K S, Shylashree N

RV College of Engineering (RVCE), Bengaluru

## Resources

- [Tiny Tapeout](https://tinytapeout.com/)
- [Tiny Tapeout FAQ](https://tinytapeout.com/faq/)
- [Digital Design Lessons](https://tinytapeout.com/digital_design/)
- [Build Your Design Locally](https://www.tinytapeout.com/guides/local-hardening/)
