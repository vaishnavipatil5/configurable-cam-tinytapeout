# SPDX-License-Identifier: Apache-2.0

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


# =========================================================
# Wait for one rising clock edge and allow gate-level delay
# =========================================================

async def one_clock(dut):
    await RisingEdge(dut.clk)
    await Timer(2, unit="ns")


# =========================================================
# Write one CAM entry
# =========================================================

async def write_entry(dut, address, data):

    dut.ui_in.value = data
    dut.uio_in.value = (1 << 3) | address

    await RisingEdge(dut.clk)

    # Allow gate-level flip-flop delay to settle
    await Timer(2, unit="ns")

    dut.uio_in.value = 0

    await Timer(1, unit="ns")


# =========================================================
# Load mask
# =========================================================

async def load_mask(dut, mask):

    dut.ui_in.value = mask
    dut.uio_in.value = (1 << 4)

    await RisingEdge(dut.clk)

    # Allow gate-level delay to settle
    await Timer(2, unit="ns")

    dut.uio_in.value = 0

    await Timer(1, unit="ns")


# =========================================================
# Perform one-clock search
# =========================================================

async def search_cam(dut, search_data):

    dut.ui_in.value = search_data
    dut.uio_in.value = (1 << 5)

    # Search is sampled on this rising edge
    await RisingEdge(dut.clk)

    # IMPORTANT:
    # Gate-level netlist uses UNIT_DELAY=#1.
    # Therefore do not read the registered result
    # immediately at the clock edge.
    await Timer(2, unit="ns")

    dut._log.info(f"DEBUG uo_out = {dut.uo_out.value}")

    # Check for X/Z before converting to integer
    value_string = str(dut.uo_out.value)

    if any(bit in value_string.lower() for bit in ["x", "z"]):
        raise AssertionError(
            f"uo_out is still unknown after search: {value_string}"
        )

    result = int(dut.uo_out.value)

    dut.uio_in.value = 0

    await Timer(1, unit="ns")

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

    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())


    # =====================================================
    # INITIALIZATION
    # =====================================================

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0


    # =====================================================
    # RESET
    # =====================================================

    dut._log.info("Applying reset")

    # Hold reset for two complete clock cycles
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
    # =====================================================

    dut._log.info("SEARCH 1: A5")

    await load_mask(dut, 0x00)

    result = await search_cam(dut, 0xA5)

    match = result & 0x01
    match_addr = (result >> 1) & 0x07

    assert match == 1, (
        f"FAIL: A5 should match, match={match}"
    )

    assert match_addr == 0, (
        f"FAIL: A5 should match address 0, "
        f"address={match_addr}"
    )

    dut._log.info("PASS: Exact match A5 -> Address 0")


    # =====================================================
    # SEARCH 2: F0
    # =====================================================

    dut._log.info("SEARCH 2: F0")

    await load_mask(dut, 0x00)

    result = await search_cam(dut, 0xF0)

    match = result & 0x01
    match_addr = (result >> 1) & 0x07

    assert match == 1, (
        f"FAIL: F0 should match, match={match}"
    )

    assert match_addr == 2, (
        f"FAIL: F0 should match address 2, "
        f"address={match_addr}"
    )

    dut._log.info("PASS: Exact match F0 -> Address 2")


    # =====================================================
    # SEARCH 3: NO MATCH
    # =====================================================

    dut._log.info("SEARCH 3: 55 - expected NO MATCH")

    await load_mask(dut, 0x00)

    result = await search_cam(dut, 0x55)

    match = result & 0x01

    assert match == 0, (
        f"FAIL: 55 should not match, match={match}"
    )

    dut._log.info("PASS: No match for 55")


    # =====================================================
    # SEARCH 4: MASKED MATCH
    # =====================================================

    dut._log.info("SEARCH 4: Masked A0 -> A5")

    await load_mask(dut, 0x0F)

    result = await search_cam(dut, 0xA0)

    match = result & 0x01
    match_addr = (result >> 1) & 0x07

    assert match == 1, (
        f"FAIL: Masked A0 should match A5, "
        f"match={match}"
    )

    assert match_addr == 0, (
        f"FAIL: Masked A0 should match address 0, "
        f"address={match_addr}"
    )

    dut._log.info("PASS: Masked match A0 -> Address 0")


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
    # =====================================================

    dut._log.info("SEARCH 5: Priority test for AA")

    await load_mask(dut, 0x00)

    result = await search_cam(dut, 0xAA)

    match = result & 0x01
    match_addr = (result >> 1) & 0x07

    dut._log.info(
        f"PRIORITY RESULT: match={match}, "
        f"address={match_addr}"
    )

    assert match == 1, (
        f"FAIL: AA should match, match={match}"
    )

    assert match_addr == 3, (
        f"FAIL: Priority should select address 3, "
        f"address={match_addr}"
    )

    dut._log.info("PASS: Priority match AA -> Address 3")


    # =====================================================
    # FINAL RESULT
    # =====================================================

    dut._log.info("======================================")
    dut._log.info("CAM TESTBENCH COMPLETED")
    dut._log.info("ALL TESTS PASSED")
    dut._log.info("ONE-CLOCK SEARCH VERIFIED")
    dut._log.info("======================================")
