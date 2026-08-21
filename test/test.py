# SPDX-License-Identifier: Apache-2.0

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly, Timer


# =========================================================
# Wait for ONE rising clock edge
# =========================================================

async def one_clock(dut):
    await RisingEdge(dut.clk)


# =========================================================
# Write one CAM entry
#
# ui_in[7:0]  = write data
# uio_in[2:0] = write address
# uio_in[3]   = write enable
# =========================================================

async def write_entry(dut, address, data):

    dut.ui_in.value = data

    # uio_in[3] = write enable
    # uio_in[2:0] = address
    dut.uio_in.value = (1 << 3) | address

    # One rising edge performs the write
    await RisingEdge(dut.clk)

    # Move to next simulation timestep
    await Timer(1, units="ps")

    # Disable write
    dut.uio_in.value = 0


# =========================================================
# Load mask
#
# ui_in[7:0] = mask
# uio_in[4]  = load mask
# =========================================================

async def load_mask(dut, mask):

    dut.ui_in.value = mask

    # uio_in[4] = load mask
    dut.uio_in.value = (1 << 4)

    # One rising edge loads the mask
    await RisingEdge(dut.clk)

    await Timer(1, units="ps")

    # Disable mask loading
    dut.uio_in.value = 0


# =========================================================
# Perform ONE-CLOCK SEARCH
#
# ui_in[7:0] = search data
# uio_in[5]  = search enable
#
# Search inputs are applied BEFORE the rising edge.
#
# ONE rising edge:
#     CAM searches
#     match and match_addr are registered
#
# Then the result is checked.
# =========================================================

async def search_cam(dut, search_data):

    # Search data
    dut.ui_in.value = search_data

    # Search enable = 1
    dut.uio_in.value = (1 << 5)

    # =====================================================
    # EXACTLY ONE RISING EDGE FOR SEARCH
    # =====================================================

    await RisingEdge(dut.clk)

    # Wait for the registered output to settle
    await ReadOnly()

    # Read output BEFORE disabling search
    result = int(dut.uo_out.value)

    # Move to next simulation timestep
    await Timer(1, units="ps")

    # Disable search
    dut.uio_in.value = 0

    return result


# =========================================================
# MAIN TEST
# =========================================================

@cocotb.test()
async def test_configurable_cam(dut):

    dut._log.info("======================================")
    dut._log.info("Starting Configurable CAM test")
    dut._log.info("======================================")


    # =====================================================
    # CLOCK
    # =====================================================

    # 10 ns period = 100 MHz
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())


    # =====================================================
    # INITIALIZATION
    # =====================================================

    dut.ena.value = 1

    dut.ui_in.value = 0
    dut.uio_in.value = 0


    # =====================================================
    # RESET
    # =====================================================

    dut._log.info("Applying reset")

    # Active-low reset
    dut.rst_n.value = 0

    # Hold reset for two rising edges
    await one_clock(dut)
    await one_clock(dut)

    # Release reset
    dut.rst_n.value = 1

    await one_clock(dut)

    dut._log.info("Reset released")


    # =====================================================
    # WRITE A5 -> ADDRESS 0
    # =====================================================

    dut._log.info("Writing A5 to address 0")

    await write_entry(dut, 0, 0xA5)


    # =====================================================
    # WRITE 3C -> ADDRESS 1
    # =====================================================

    dut._log.info("Writing 3C to address 1")

    await write_entry(dut, 1, 0x3C)


    # =====================================================
    # WRITE F0 -> ADDRESS 2
    # =====================================================

    dut._log.info("Writing F0 to address 2")

    await write_entry(dut, 2, 0xF0)


    # =====================================================
    # SEARCH 1: A5
    #
    # Expected:
    # match = 1
    # address = 0
    # =====================================================

    dut._log.info("SEARCH 1: A5")

    await load_mask(dut, 0x00)

    result = await search_cam(dut, 0xA5)

    match = result & 0x01
    match_addr = (result >> 1) & 0x07

    assert match == 1, \
        f"FAIL: A5 should match, match={match}"

    assert match_addr == 0, \
        f"FAIL: A5 should match address 0, address={match_addr}"

    dut._log.info("PASS: Exact match A5 -> Address 0")


    # =====================================================
    # SEARCH 2: F0
    #
    # Expected:
    # match = 1
    # address = 2
    # =====================================================

    dut._log.info("SEARCH 2: F0")

    await load_mask(dut, 0x00)

    result = await search_cam(dut, 0xF0)

    match = result & 0x01
    match_addr = (result >> 1) & 0x07

    assert match == 1, \
        f"FAIL: F0 should match, match={match}"

    assert match_addr == 2, \
        f"FAIL: F0 should match address 2, address={match_addr}"

    dut._log.info("PASS: Exact match F0 -> Address 2")


    # =====================================================
    # SEARCH 3: NO MATCH
    #
    # Search = 55
    # Expected match = 0
    # =====================================================

    dut._log.info("SEARCH 3: 55 - expected NO MATCH")

    await load_mask(dut, 0x00)

    result = await search_cam(dut, 0x55)

    match = result & 0x01

    assert match == 0, \
        f"FAIL: 55 should not match, match={match}"

    dut._log.info("PASS: No match for 55")


    # =====================================================
    # SEARCH 4: MASKED MATCH
    #
    # Stored:
    # A5 = 1010 0101
    #
    # Search:
    # A0 = 1010 0000
    #
    # Mask:
    # 0F = 0000 1111
    #
    # Lower four bits are ignored.
    #
    # Expected:
    # match = 1
    # address = 0
    # =====================================================

    dut._log.info("SEARCH 4: Masked A0 -> A5")

    await load_mask(dut, 0x0F)

    result = await search_cam(dut, 0xA0)

    match = result & 0x01
    match_addr = (result >> 1) & 0x07

    assert match == 1, \
        f"FAIL: Masked A0 should match A5, match={match}"

    assert match_addr == 0, \
        f"FAIL: Masked A0 should match address 0, address={match_addr}"

    dut._log.info("PASS: Masked match A? -> Address 0")


    # =====================================================
    # WRITE AA -> ADDRESS 3
    # =====================================================

    dut._log.info("Writing AA to address 3")

    await write_entry(dut, 3, 0xAA)


    # =====================================================
    # WRITE AA -> ADDRESS 5
    # =====================================================

    dut._log.info("Writing AA to address 5")

    await write_entry(dut, 5, 0xAA)


    # =====================================================
    # SEARCH 5: PRIORITY
    #
    # Address 3 = AA
    # Address 5 = AA
    #
    # Both match.
    #
    # Address 3 has priority.
    #
    # Expected:
    # match = 1
    # address = 3
    # =====================================================

    dut._log.info("SEARCH 5: Priority test for AA")

    await load_mask(dut, 0x00)

    result = await search_cam(dut, 0xAA)

    match = result & 0x01
    match_addr = (result >> 1) & 0x07

    dut._log.info(
        f"PRIORITY RESULT: match={match}, address={match_addr}"
    )

    assert match == 1, \
        f"FAIL: AA should match, match={match}"

    assert match_addr == 3, \
        f"FAIL: Priority should select address 3, address={match_addr}"

    dut._log.info("PASS: Priority match AA -> Address 3")


    # =====================================================
    # FINAL RESULT
    # =====================================================

    dut._log.info("======================================")
    dut._log.info("CAM TESTBENCH COMPLETED")
    dut._log.info("ALL TESTS PASSED")
    dut._log.info("ONE-CLOCK SEARCH VERIFIED")
    dut._log.info("======================================")
