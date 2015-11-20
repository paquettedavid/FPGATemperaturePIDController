# FPGATemperaturePIDController
PID control of a DC fan for regulating FPGA processor temperature, in VHDL. The FPGA used here is the Nexys4DDR.

The desired temperature is set by two push buttons.

The desired temperature, current temperature and PWM fan speed percent is written to bram memory and displayed on a connected VGA display.

Module communication is handled by the Wishbone bus.
##Serial Communication
Current temperature and fan speed are sent through uart serial over the rs232 micro-usb port(in hex not ascii), UART library from: https://github.com/pabennett/uart
Some connection settings:
  Baud: 115200
  Data bits: 8
  parity: none
  Stop bits: 1
Serial format is as follows:
  XX 2C XX A0
  (temperature) 2C (fanSpeed) A0
  where XX is a 2 digit hex number, and 2C is ascii for a comma(,) and A0 is ascii for a newline(\n)

All code is located in the folder: VDHL Modules
