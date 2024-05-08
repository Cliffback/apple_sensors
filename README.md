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

## License
BSD 3-Clause License

Copyright (c) 2016-2018, "freedom" Koan-Sin Tan
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



