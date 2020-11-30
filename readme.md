# Temperature Sensor Monitor for Apple Silicon M1 

- `temp_sensor.m`: A modified version of the Objective-C [code](https://github.com/freedomtan/sensors/blob/master/sensors/sensors.m) for iOS sensor by [freedomtan](https://github.com/freedomtan);

- `monitor.cpp`: A naive C++ wrapper for `temp_sensor.m` output for monitoring temperature in the terminal.

## Usage

Compile `temp_sensor.m` and `monitor.cpp` individually. Then

`./temp_sensor | ./monitor` or `./temp_sensor` 

Only test with my Mac mini with M1. Please check your mac's `ioreg -lfx` output to make changes in `temp_sensor.m` if needed.

## References

For **better names** (e.g. what is `PMU TP3w` ?) for the sensors, please refer to 

https://github.com/exelban/stats/blob/master/Modules/Sensors/values.swift

https://github.com/acidanthera/VirtualSMC/blob/master/Docs/SMCSensorKeys.txt

Here is a similar code in swift for getting sensor values using IOKit (for intel Mac)

https://github.com/exelban/stats/blob/master/Modules/Sensors/values.swift

For intel Mac, an easier way to get sensor infomation:

`sudo powermetrics`



## Demo: screen shot and screen record
- screen record : screen_record.mp4[1.4MB] or
![screen record](https://raw.githubusercontent.com/fermion-star/apple_sensors/master/screen_record.low.gif)

- screen shot 
![screen shot](https://raw.githubusercontent.com/fermion-star/apple_sensors/master/screen_shot.png) 
<!---
![screen record](screen_record.mp4)

![screen shot](screen_shot.png) 
--->



