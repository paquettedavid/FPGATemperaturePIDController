# FPGATemperaturePIDController
PID control of a DC fan for regulating FPGA processor temperature. The FPGA used here is the Nexys4DDR.

The desired temperatrue is set by two push buttons.

The desired temperature, current temperature and PWM fan speed percent is written to bram memory and displayed on a connected VGA display.

Module communication is handled by the Wishbone bus.

