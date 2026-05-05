# EX/MEM Data Forwarding Optimization — MIPS Pipeline

## What Changed

We added **data forwarding** (bypassing) to our 5-stage MIPS pipeline, eliminating the NOP instructions previously required between dependent instructions.

| File | Change |
|------|--------|
| `forwarding_unit.v` | **NEW** — Detects data hazards by comparing source registers against destination registers of in-flight instructions |
| `execute.v` | Added two 3-to-1 forwarding muxes before ALU inputs A and B |
| `idExLatch.v` | Added `rs` (instr[25:21]) passthrough for the forwarding unit |
| `decode.v` | Passes `rs` field through the ID/EX latch |
| `mips_pipeline.v` | Instantiates forwarding unit, wires forwarded data paths |

## How It Works

Each cycle, the forwarding unit compares the current instruction's source registers (`id_ex_rs`, `id_ex_rt`) against the destination registers of the two prior instructions (`ex_mem_rd`, `mem_wb_rd`). On a match, the computed result is routed directly to the ALU input, bypassing the register file.

```
Forward select encoding:
  00 = No forwarding (use register file value)
  10 = Forward from EX/MEM latch (1 cycle ago)
  01 = Forward from MEM/WB latch (2 cycles ago)
```

## Results

| Metric | Without Forwarding | With Forwarding |
|--------|-------------------|-----------------|
| Total instructions | 24 | 9 |
| Wasted NOP cycles | 12 | 2 |
| PC range | 0–96 | 0–36 |
| Final `$1` | **12** | **12** |

The 2 remaining NOPs handle the **load-use hazard** — LW results are not available until the MEM stage, which forwarding alone cannot resolve without a stall unit.

---

## Timing Diagram Analysis

![Optimization Timing Diagram](JanneOptimizationDiagram.png)

### Signal Index

| Row | Signal | Description |
|-----|--------|-------------|
| 4–7 | `[0]`–`[3]` | Register file contents |
| 9 | `pc_current` | Program Counter |
| 10 | `if_id_instr` | Fetched instruction word |
| 12 | `id_ex_rs` | Source register 1 of current EX-stage instruction |
| 13 | `id_ex_rt` | Source register 2 of current EX-stage instruction |
| 14 | `ex_mem_rd` | Destination register from previous instruction (MEM stage) |
| 15 | `ex_mem_regwrite` | Whether MEM-stage instruction writes a register |
| 16 | `mem_wb_rd` | Destination register from two-back instruction (WB stage) |
| 17 | `mem_wb_regwrite` | Whether WB-stage instruction writes a register |
| 18 | `forward_a` | Forwarding mux select for ALU input A |
| 19 | `forward_b` | Forwarding mux select for ALU input B |
| 21 | `alu_a_forwarded` | Value fed to ALU input A (after forwarding mux) |
| 22 | `alu_b_forwarded` | Value fed to ALU input B (after forwarding mux) |
| 23 | `ex_mem_alu_result` | ALU result stored in EX/MEM latch |
| 26 | `wb_write_data` | Value written back to register file |

### Forwarding Trace

**ADD $1,$1,$2 (~80ns)** — No forwarding needed. LW instructions already completed writeback. Row 18 = 0, Row 19 = 0. Row 21 = 1 (from register file), Row 22 = 2 (from register file). Row 23 = 3 (ALU: 1+2).

**ADD $1,$1,$3 (~90ns)** — Forwarding activates. Row 14 (`ex_mem_rd`) = 1 matches Row 12 (`id_ex_rs`) = 1, and Row 15 (`ex_mem_regwrite`) = 1. The forwarding unit sets Row 18 (`forward_a`) = 2 (EX/MEM forward). Row 21 now shows 3, grabbed directly from the EX/MEM latch instead of the stale register file value of 1. Row 23 = 6 (ALU: 3+3).

**ADD $1,$1,$1 (~100ns)** — Double forward. Both rs and rt are register 1, both match `ex_mem_rd` = 1. Row 18 = 2, Row 19 = 2. Row 21 = 6 (forwarded), Row 22 = 6 (forwarded). Row 23 = 12 (ALU: 6+6).

**ADD $1,$1,$0 (~110ns)** — Single forward. Row 18 = 2 (forwards 12 for $1), Row 19 = 0 ($0 is always zero). Row 23 = 12 (ALU: 12+0). Final result confirmed.

### Summary

| Instruction | Row 18 | Row 19 | Row 21 (ALU A) | Row 22 (ALU B) | Result |
|-------------|:------:|:------:|:--------------:|:--------------:|:------:|
| ADD $1,$1,$2 | 0 | 0 | 1 (regfile) | 2 (regfile) | 3 |
| ADD $1,$1,$3 | 2 | 0 | 3 (forwarded) | 3 (regfile) | 6 |
| ADD $1,$1,$1 | 2 | 2 | 6 (forwarded) | 6 (forwarded) | 12 |
| ADD $1,$1,$0 | 2 | 0 | 12 (forwarded) | 0 (regfile) | 12 |

Row 5 (`registers[1]`) confirms: 0 → 1 → 3 → 6 → 12.

---

## Vivado Simulation

1. Add all `.v` files from `design_sources/` as design sources
2. Add `mips_pipeline_tb.v` from `simulation/` as simulation source
3. Copy `.mem` files from `simulation/` to the xsim working directory
4. After launching simulation, run these Tcl commands:

```tcl
add_wave_divider "REGISTERS"
add_wave /mips_pipeline_tb/uut/stage2_decode/rf0/registers[0]
add_wave /mips_pipeline_tb/uut/stage2_decode/rf0/registers[1]
add_wave /mips_pipeline_tb/uut/stage2_decode/rf0/registers[2]
add_wave /mips_pipeline_tb/uut/stage2_decode/rf0/registers[3]
add_wave_divider "FETCH"
add_wave /mips_pipeline_tb/uut/stage1_fetch/pc_current
add_wave /mips_pipeline_tb/uut/if_id_instr
add_wave_divider "FORWARDING"
add_wave /mips_pipeline_tb/uut/fwd_unit/id_ex_rs
add_wave /mips_pipeline_tb/uut/fwd_unit/id_ex_rt
add_wave /mips_pipeline_tb/uut/fwd_unit/ex_mem_rd
add_wave /mips_pipeline_tb/uut/fwd_unit/ex_mem_regwrite
add_wave /mips_pipeline_tb/uut/fwd_unit/mem_wb_rd
add_wave /mips_pipeline_tb/uut/fwd_unit/mem_wb_regwrite
add_wave /mips_pipeline_tb/uut/fwd_unit/forward_a
add_wave /mips_pipeline_tb/uut/fwd_unit/forward_b
add_wave_divider "EXECUTE"
add_wave /mips_pipeline_tb/uut/stage3_execute/alu_a_forwarded
add_wave /mips_pipeline_tb/uut/stage3_execute/alu_b_forwarded
add_wave /mips_pipeline_tb/uut/ex_mem_alu_result
add_wave /mips_pipeline_tb/uut/ex_mem_write_reg
add_wave_divider "WRITEBACK"
add_wave /mips_pipeline_tb/uut/wb_write_data
restart
run 300ns
```

5. Right-click signals → **Radix → Unsigned Decimal** for readable values.
