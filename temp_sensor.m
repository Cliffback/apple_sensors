// This code is originally from
// https://github.com/freedomtan/sensors/blob/master/sensors/sensors.m Here is
// the original code's license

// BSD 3-Clause License

// Copyright (c) 2016-2018, "freedom" Koan-Sin Tan
// All rights reserved.

// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:

// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.

// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.

// * Neither the name of the copyright holder nor the names of its
//   contributors may be used to endorse or promote products derived from
//   this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#include <Foundation/Foundation.h>
#include <IOKit/hidsystem/IOHIDEventSystemClient.h>
#include <stdio.h>

// Declarations from other IOKit source code

typedef struct __IOHIDEvent *IOHIDEventRef;
typedef struct __IOHIDServiceClient *IOHIDServiceClientRef;
#ifdef __LP64__
typedef double IOHIDFloat;
#else
typedef float IOHIDFloat;
#endif

IOHIDEventSystemClientRef
IOHIDEventSystemClientCreate(CFAllocatorRef allocator);
int IOHIDEventSystemClientSetMatching(IOHIDEventSystemClientRef client,
                                      CFDictionaryRef match);
int IOHIDEventSystemClientSetMatchingMultiple(IOHIDEventSystemClientRef client,
                                              CFArrayRef match);
IOHIDEventRef IOHIDServiceClientCopyEvent(IOHIDServiceClientRef, int64_t,
                                          int32_t, int64_t);
CFStringRef IOHIDServiceClientCopyProperty(IOHIDServiceClientRef service,
                                           CFStringRef property);
IOHIDFloat IOHIDEventGetFloatValue(IOHIDEventRef event, int32_t field);

// create a dict ref, like for temperature sensor {"PrimaryUsagePage":0xff00,
// "PrimaryUsage":0x5}
CFDictionaryRef matching(int page, int usage) {
  CFNumberRef nums[2];
  CFStringRef keys[2];

  keys[0] = CFStringCreateWithCString(0, "PrimaryUsagePage", 0);
  keys[1] = CFStringCreateWithCString(0, "PrimaryUsage", 0);
  nums[0] = CFNumberCreate(0, kCFNumberSInt32Type, &page);
  nums[1] = CFNumberCreate(0, kCFNumberSInt32Type, &usage);

  CFDictionaryRef dict = CFDictionaryCreate(
      0, (const void **)keys, (const void **)nums, 2,
      &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
  return dict;
}

CFArrayRef getProductNames(CFDictionaryRef sensors) {
  IOHIDEventSystemClientRef system =
      IOHIDEventSystemClientCreate(kCFAllocatorDefault); // in CFBase.h = NULL
  // ... this is the same as using kCFAllocatorDefault or the return value from
  // CFAllocatorGetDefault()
  IOHIDEventSystemClientSetMatching(system, sensors);
  CFArrayRef matchingsrvs = IOHIDEventSystemClientCopyServices(
      system); // matchingsrvs = matching services

  long count = CFArrayGetCount(matchingsrvs);
  CFMutableArrayRef array =
      CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);

  for (int i = 0; i < count; i++) {
    IOHIDServiceClientRef sc =
        (IOHIDServiceClientRef)CFArrayGetValueAtIndex(matchingsrvs, i);
    CFStringRef name = IOHIDServiceClientCopyProperty(
        sc, CFSTR("Product")); // here we use ...CopyProperty
    if (name) {
      CFArrayAppendValue(array, name);
    } else {
      CFArrayAppendValue(array,
                         @"noname"); // @ gives a Ref like in "CFStringRef name"
    }
  }
  return array;
}

// from IOHIDFamily/IOHIDEventTypes.h
// e.g.,
// https://opensource.apple.com/source/IOHIDFamily/IOHIDFamily-701.60.2/IOHIDFamily/IOHIDEventTypes.h.auto.html

#define IOHIDEventFieldBase(type) (type << 16)
#define kIOHIDEventTypeTemperature 15
#define kIOHIDEventTypePower 25

CFArrayRef getPowerValues(CFDictionaryRef sensors) {
  IOHIDEventSystemClientRef system =
      IOHIDEventSystemClientCreate(kCFAllocatorDefault);
  IOHIDEventSystemClientSetMatching(system, sensors);
  CFArrayRef matchingsrvs = IOHIDEventSystemClientCopyServices(system);

  long count = CFArrayGetCount(matchingsrvs);
  CFMutableArrayRef array =
      CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
  for (int i = 0; i < count; i++) {
    IOHIDServiceClientRef sc =
        (IOHIDServiceClientRef)CFArrayGetValueAtIndex(matchingsrvs, i);
    IOHIDEventRef event =
        IOHIDServiceClientCopyEvent(sc, kIOHIDEventTypePower, 0, 0);

    CFNumberRef value;
    if (event != 0) {
      double temp = IOHIDEventGetFloatValue(
          event, IOHIDEventFieldBase(kIOHIDEventTypePower));
      value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
    } else {
      double temp = 0;
      value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
    }
    CFArrayAppendValue(array, value);
  }
  return array;
}

CFArrayRef getThermalValues(CFDictionaryRef sensors) {
  IOHIDEventSystemClientRef system =
      IOHIDEventSystemClientCreate(kCFAllocatorDefault);
  IOHIDEventSystemClientSetMatching(system, sensors);
  CFArrayRef matchingsrvs = IOHIDEventSystemClientCopyServices(system);

  long count = CFArrayGetCount(matchingsrvs);
  CFMutableArrayRef array =
      CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);

  for (int i = 0; i < count; i++) {
    IOHIDServiceClientRef sc =
        (IOHIDServiceClientRef)CFArrayGetValueAtIndex(matchingsrvs, i);
    IOHIDEventRef event = IOHIDServiceClientCopyEvent(
        sc, kIOHIDEventTypeTemperature, 0, 0); // here we use ...CopyEvent

    CFNumberRef value;
    if (event != 0) {
      double temp = IOHIDEventGetFloatValue(
          event, IOHIDEventFieldBase(kIOHIDEventTypeTemperature));
      value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
    } else {
      double temp = 0;
      value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
    }
    CFArrayAppendValue(array, value);
  }
  return array;
}

void dumpValues(CFArrayRef values) {
  long count = CFArrayGetCount(values);
  for (int i = 0; i < count; i++) {
    CFNumberRef value = CFArrayGetValueAtIndex(values, i);
    double temp = 0.0;
    CFNumberGetValue(value, kCFNumberDoubleType, &temp);
    // NSLog(@"value = %lf\n", temp);
    printf("%0.1lf, ", temp);
  }
}

void dumpNames(CFArrayRef names, char *cat) {
  long count = CFArrayGetCount(names);
  for (int i = 0; i < count; i++) {
    NSString *name = (NSString *)CFArrayGetValueAtIndex(names, i);
    // NSLog(@"value = %lf\n", temp);
    // printf("%s (%s), ", [name UTF8String], cat);
    printf("%s, ", [name UTF8String]);
  }
}

NSArray *currentArray() {
  CFDictionaryRef currentSensors = matching(0xff08, 2);
  return CFBridgingRelease(getProductNames(currentSensors));
}

NSArray *voltageArray() {
  CFDictionaryRef currentSensors = matching(0xff08, 3);
  return CFBridgingRelease(getProductNames(currentSensors));
}

NSArray *thermalArray() {
  CFDictionaryRef currentSensors = matching(0xff00, 5);
  return CFBridgingRelease(getProductNames(currentSensors));
}

NSArray *returnCurrentValues() {
  CFDictionaryRef currentSensors = matching(0xff08, 2);
  return CFBridgingRelease(getPowerValues(currentSensors));
}

NSArray *returnVoltageValues() {
  CFDictionaryRef voltageSensors = matching(0xff08, 3);
  return CFBridgingRelease(getPowerValues(voltageSensors));
}

NSArray *returnThermalValues() {
  CFDictionaryRef currentSensors = matching(0xff00, 5);
  return CFBridgingRelease(getThermalValues(currentSensors));
}

// Function to filter sensor names by a specific property
CFArrayRef filterSensorNamesByProperty(CFArrayRef sensorNames,
                                       NSString *property) {
  CFMutableArrayRef filteredNames =
      CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);

  long count = CFArrayGetCount(sensorNames);
  for (int i = 0; i < count; i++) {
    NSString *name = (NSString *)CFArrayGetValueAtIndex(sensorNames, i);
    if ([name rangeOfString:property].location != NSNotFound) {
      CFArrayAppendValue(filteredNames, name);
    }
  }

  return filteredNames;
}

// Function to filter and dump sensor names and values by a specific property
void dumpSensorDataByProperty(CFArrayRef sensorNames, CFArrayRef sensorValues,
                              NSString *property) {
  CFArrayRef filteredNames = filterSensorNamesByProperty(sensorNames, property);
  long count = CFArrayGetCount(filteredNames);

  for (int i = 0; i < count; i++) {
    NSString *name = (NSString *)CFArrayGetValueAtIndex(filteredNames, i);
    printf("%s, ", [name UTF8String]);

    CFNumberRef value = CFArrayGetValueAtIndex(sensorValues, i);
    double temp = 0.0;
    CFNumberGetValue(value, kCFNumberDoubleType, &temp);
    printf("%0.1lf, ", temp);
  }

  printf("\n");
}

void calcAverageTempByProperty(CFArrayRef sensorNames, CFArrayRef sensorValues,
                               NSString *property) {
  CFArrayRef filteredNames = filterSensorNamesByProperty(sensorNames, property);
  long count = CFArrayGetCount(filteredNames);

  double sum = 0.0; // Variable to store the sum of sensor values

  for (int i = 0; i < count; i++) {
    CFNumberRef value = CFArrayGetValueAtIndex(sensorValues, i);
    double temp = 0.0;
    CFNumberGetValue(value, kCFNumberDoubleType, &temp);
    sum += temp; // Accumulate the sensor values
  }

  double average = sum / count; // Calculate the average value

  printf("Average value of %s: %0.1lf\n", [property UTF8String], average);
}

void calcAverageTemp(CFArrayRef sensorValues) {
  long count = CFArrayGetCount(sensorValues);

  double sum = 0.0; // Variable to store the sum of sensor values

  for (int i = 0; i < count; i++) {
    CFNumberRef value = CFArrayGetValueAtIndex(sensorValues, i);
    double temp = 0.0;
    CFNumberGetValue(value, kCFNumberDoubleType, &temp);
    sum += temp; // Accumulate the sensor values
  }

  double average = sum / count; // Calculate the average value

  printf("Average value: %0.1lf\n", average);
}

int main(int argc, char *argv[]) {
  // Create default values
  NSString *property = nil;
  BOOL calculateAverage = NO;

  // Loop through command-line arguments to determine actions
  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "-a") == 0) {
      calculateAverage = YES;
    } else if (strcmp(argv[i], "-f") == 0) {
      if (i + 1 < argc) {
        property = [NSString stringWithUTF8String:argv[i + 1]];
        i++; // Skip next argument (property)
      } else {
        printf("Error: Missing argument for -f\n");
        return 1;
      }
    } else {
      printf("Error: Invalid argument: %s\n", argv[i]);
      return 1;
    }
  }

  // Retrieve sensor data
  CFDictionaryRef thermalSensors = matching(0xff00, 5);
  CFArrayRef thermalNames = getProductNames(thermalSensors);
  CFArrayRef thermalValues = getThermalValues(thermalSensors);

  // Determine action based on arguments
  if (calculateAverage) {
    if (property) {
      calcAverageTempByProperty(thermalNames, thermalValues, property);
    } else {
      calcAverageTemp(thermalValues);
    }
  } else if (property) {
    dumpSensorDataByProperty(thermalNames, thermalValues, property);
  } else {
    dumpNames(thermalNames, "C");
    printf("\n");
    fflush(stdout);
    dumpValues(thermalValues);
  }

  return 0;
}
