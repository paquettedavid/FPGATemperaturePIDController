## FPGA Temperature Controller
PID control of a DC fan for regulating FPGA processor temperature, in VHDL.

###Hardware Info
 
The desired temperature is set by two push buttons(located on the FPGA).
The desired temperature, current temperature and PWM fan speed percent is written to bram(located on the FPGA) memory and displayed on a connected VGA display. 
######FGPA
The FPGA used is the Nexys4DDR: http://digilentinc.com/nexys4ddr/
######DC Fan
 used: (link here)
 Deadzone from 0 to 20% duty cycle, using power source of 5VDC.
 PWM frequency tested from 300 to 600Hz.
######PWM Motor Driver
 Used a single power nMOSFET for driving an external 5VDC signal using the onboard 3.3VDC signal.    
 nMOSFET (Vth(max)=2.35V): https://www.adafruit.com/products/355     
######Temperature Sensor
Used the onboard FPGA temperature sensor on the processor, using the XDAC interface provided by Xilinx 
######Serial UART
comm chip located on the FPGA  
######Push Buttons
BTNU and BTND are used to increment and decrement the setpoint, these are located on the fgpa dev board
######VGA
Any stanard VGA display should work fine  
Temperature sensor used was
######Power supply
used: (link here)     
Currently using the built in usb ports on my laptop.


###PWM Control Signal Info
PWM output is configured on JA pin 1 (ja(0)).  
0 to 100% duty cycle modulation with 6-bit resolution. 0 to 3.3VDC.  
External circuit needed to power the dc motor.  

##Motor Driver Circuit
3.3VDC to 5.0VDC logic shifter for pwm dc motor control.   

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

###PID Control/Data Analysis Info
All data was captured using the serial output, the python script inside the DataAnalysisSource directory converts the serial output to a more readable format(converts the mixed ascii/hex to normal integers) and saves it to a file so it can be read by MATLAB.    
###### Control Analysis
Sampling rate of 0.01 seconds (10 milliseconds)


System model:

G(s)=K/(1+Tp1*s)
where,
K=-4.7251
Tp1=-4.4746

Controller:      
1 
Kp + Ki*(1/s)
where,
Kp=-0.303
Ki=-0.123

  Open loop transfer function was computed using the System Identiitfication toolbox in MATLAB using data collected with the UART module.  
  PID gains were computed using the PIDTuner toolbox in MATLAB.  
  Closed loop transfer function computed in MATLAB.  
