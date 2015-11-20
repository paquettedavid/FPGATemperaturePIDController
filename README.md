## FPGA Temperature Controller
PID control of a DC fan for regulating FPGA processor temperature, in VHDL.

###Hardware Info
The FPGA used here is the Nexys4DDR.  
The desired temperature is set by two push buttons(located on the FPGA).
The desired temperature, current temperature and PWM fan speed percent is written to bram(located on the FPGA) memory and displayed on a connected VGA display.  
DC fan used: (link here)  
PWM motor driver used: (link here)  
Power supply used: (link here)  
Serial UART comm chip: located on the FPGA  

###Bus Info
Module communication is handled by the Wishbone bus.  
TemperatureControlMaster, wb_vga are Wishbone masters  
wb_bram is a Wishbone slave  

###Serial Communication
Current temperature and fan speed are sent through uart serial over the rs232 micro-usb port(in hex not ascii).  
UART library from: https://github.com/pabennett/uart  
Some connection settings:  
  Baud: 115200  
  Data bits: 8  
  parity: none  
  Stop bits: 1  
#####Serial format is as follows:  
  XX 2C XX A0  
  (temperature) 2C (fanSpeed) A0  
  where XX is a 2 digit hex number, and 2C is ascii for a comma(,) and A0 is ascii for a newline(\n)  

###PID Control Info
  Open loop transfer function was computed using the System Identiitfication toolbox in MATLAB using data collected with the UART module.  
  PID gains were computed using the PIDTuner toolbox in MATLAB.  
  Closed loop transfer function computed in MATLAB.  
