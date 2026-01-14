# digital_oscilloscope_basys3

A **Basys 3 (Artix-7)** FPGA-based **digital oscilloscope** built in **VHDL**.  
Sampling is done via the Xilinx **XADC** using **VAUX6**, and the waveform/UI is rendered over **VGA (640×480)**.

- FPGA: **xc7a35tcpg236-1** (Basys 3)
- Project created with: **Vivado 2024.2**

## Repository structure

- `src/` — VHDL sources (top-level + modules)
- `constraints/` — Basys 3 pin/timing constraints (`constraints.xdc`)
- `ip/` — Vivado IP configs (`*.xci`) only (no generated output products)
- `scripts/` — helper scripts (project recreation)
- `vivado_reference/` — the original `.xpr` kept only as a reference

## Main modules (high level)

- `oscilloscope_top.vhd` — top-level: buttons/switches, XADC, VGA, 7-seg, LEDs
- `xadc_module.vhd` — reads VAUX6 via XADC DRP; outputs 12-bit samples + valid pulse  
  - note: it currently triggers a DRP read every **2500 clk cycles** (`>= 2499`)
- `vga_controller.vhd` — VGA timing generator (**640×480**) and pixel coordinates
- `simple_text_display.vhd`, `text_generator.vhd`, ROM files — text/overlay rendering
- `block_ram.vhd` + `blk_mem_gen_0` — sample buffer / memory
- `seven_segment_driver.vhd`, `display_decoder.vhd` — 7-seg UI

## Controls (as implemented in `oscilloscope_features.vhd`)

- `BTN_CENTER` cycles UI modes (trigger / vertical position / volts-per-division / time-per-division, etc.)
- `BTN_UP / BTN_DOWN / BTN_LEFT / BTN_RIGHT` adjust the active setting
- `SW[12]` toggles an auto mode flag (see source)
- `SW[0]` affects run/hold mode logic (see source)

> Tip: If you want, we can document the UI behavior more explicitly after you confirm what you expect each button/switch to do on hardware.

## Build (recommended): recreate the project from sources

This repo does **not** store Vivado build artifacts (`.runs/`, `.cache/`, etc.).  
Instead, recreate the Vivado project using the provided Tcl script:

```bash
# from the repo root
vivado -mode batch -source scripts/create_project.tcl -tclargs ./_vivado
```

Then open the generated project:
- `_vivado/digital_oscilloscope_basys3/digital_oscilloscope_basys3.xpr`

### Notes on IP
The `ip/` folder contains only `*.xci` files. When the project is created, Vivado will regenerate the IP output products.

## Hardware notes (XADC)
- The design reads XADC **VAUX6**.
- Make sure your analog input respects the XADC input range and Basys 3 analog pin requirements (external scaling/protection may be needed).

## License
MIT (can be changed if you prefer).
