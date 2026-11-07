# Build Notes

This project was authored for **Xilinx ISE / Spartan-3E**, not Vivado. The original project file `Project1_Cache_Controller.xise` references VHDL and IP configuration files relative to its directory, so those files are deliberately kept in the same positions as the original project.

## Project Files

- **Top entity:** `project1` (`project1.vhd`)
- **Testbench:** `tb_project1.vhd`
- **Target FPGA:** `xc3s500e`, package `fg320`, speed grade `-5`
- **Pin constraints:** `project1.ucf` (`clk` on `C9`, `rst` on `L13`)
- **Source order:** `project1.prj`
- **Testbench simulation metadata:** `tb_project1.prj`
- **Xilinx IP:** `ipcore_dir/bram`, `ipcore_dir/icon`, and `ipcore_dir/ila`

## Xilinx IP

The project includes `*.xco` Core Generator configuration files, `*.vhd` generated wrappers, and the three corresponding `*.ngc` netlists that were present in the original project. The ISE project also references the `*.xise` IP project entries. These vendor-generated files may be subject to Xilinx licensing restrictions; check the applicable terms before redistributing or using them outside the supported toolchain.

## Opening in ISE

Open `Project1_Cache_Controller.xise` from this folder. The original relative references will resolve without rewriting the project. The model uses a 50 MHz clock; `tb_project1.vhd` produces a 20 ns period, asserts reset initially, then releases it after 200 ns.

For synthesis, use the original project configuration. Recreate the design with Xilinx ISE, not a generic C/C++ compiler. A hardware build and ChipScope capture require the target board and supported legacy Xilinx tools. The current GitHub preparation preserved source and project metadata but did not rerun the full FPGA toolchain.
