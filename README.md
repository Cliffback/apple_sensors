# Temperature Sensor Tool for Apple Silicon
This code is based on [temp_sensor.m](https://github.com/fermion-star/apple_sensors/temp_sensor.m) by [fermion-star](https://github.com/fermion-star) which was in turn was based on [sensors.m](https://github.com/freedomtan/sensors/blob/master/sensors/sensors.m) by [freedomtan](https://github.com/freedomtan)

## Description
The purpose of this tool is to quickly retrieve temperature information on macOS arm64 / Apple Silicone, either for use in other applications. The output can be modified with arguments for specific readings or average temperatures.

## Usage
To run the application, use the following command:
```bash
./application [options]
```
### Options
- `-a`: Calculate average temperature.
- `-f [property]`: Filter data by property.
- `-r [interval]`: Repeat the operation with a specified interval.

All arguments can be combined in whatever order.

### Example Usage
Calculate average temperature:
```bash
./application -a
```
Filter data by property:
```bash
./application -f "PMU tdev"
```
Repeat operation with a 5-second interval:

```bash
./application -r 5
```
## Dependencies
- Xcode

## Building from Source
```bash
clang -Wall -v temp_sensor.m -framework IOKit -framework Foundation -o temp_sensor
```

## References

For **better names** (e.g. what is `PMU TP3w` ?) for the sensors, please refer to

https://github.com/exelban/stats/blob/master/Modules/Sensors/values.swift

https://github.com/acidanthera/VirtualSMC/blob/master/Docs/SMCSensorKeys.txt

Here is a similar code in swift for getting sensor values using IOKit (for intel Mac)

https://github.com/exelban/stats/blob/master/Modules/Sensors/values.swift
