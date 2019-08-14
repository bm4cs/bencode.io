---
layout: post
title: "Reverse Engineering An Introduction"
date: "2019-02-25 08:44:10"
comments: false
categories: [dev]
tags: [infosec]
---


# Malware Delivery and Exploitation

Attack vector is the method used to infect malware (buffer overflow, macro in Excel).

Attack surface, parts of software where malicious data is injected. Secure software should minimise this attack surface.

## Attack surfaces

* Passing arbitrary untrusted input
* Complex software is inheritently more at risk.

Reducing attack surface:

* Removing legacy code
* Refactoring
* 




## Social Engineering




## Phishing

* Might know about SOE or version information of products.



## Physical Access

* Attacking exposed inferfaces
* USB, PCIe
* May expose vulnerable software, device driver
* USB: inline HIDS device, keyboard traffic


Things like HDMI and DVI have bidirectional I2C communications protocols. Fuzzing these communication channels has shown system crashes.



## Software Exploitation

Server-side:

* `sendmail` exploit
* SQL injection


Client-side:

* Buffer overflow in Adobe Reader



## Escalations and Escapes

Sandbox escape, 
Privilege escalation,

Kernel exploits are often required.


## Kernel Attack Surfaces

Drivers are a popular source of bugs. Example, a USB driver, just emulate the device to exercise the vulnerability as needed.



## Over the Air Attacks

Baseband processor on phones, typically run their own real-time operating system (RTOS).

Hexagon made by Qualcomm.

Baseband security is well behind the state-of-the-art security.

Not heavily audited. Custom heap allocators. Fuzzing causing many crashes.


## Base Band (BB) to Application Processor (AP)





# Side Channel Attacks


Side channel attacks avoid breaking the security of a system directly. More focused at the physical implementation of a security system.

* Timing - based on the idea different computations take differing amounts of time. `strcmp` doing a password check for example. Secure software will attempt to have constant time operations.
* Power
* Accoustic
* Cache
* Radio frequency (RF)

Glitching attacks, are mostly FPGA (?) based. FPGA coded in hardware description language (such as verilog). 




# Embedded Devices and Firmware

How can one verify that an embedded device or firmware or BIOS/UEFI hasn't been modified?

Physical techniques to dump firmware images.

Interfacing techniques:

* SPI
* I2C (I squared C)
* UART 


## UART breakdown

Short for Universal Asynchronous Receiver Transmitter, is a microcontroller that provides a serial communication interface to a (turing) machine.

* Only uses two wires, Tx and Rx.
* Its serial. Bytes are converted into a single serial bit stream for outbound transmission. The opposite for inbound, the serial bit stream is converted into bytes compatible with the machine architecture.
* Physical interfaces generally have 4 for more pins, typically VCC, Tx (transmit), Rx (receive) and ground.
* 3.3v is common



### Pin Hunting


First up the ground pin:

* Ground. Easy, using a multimeter in continuity mode, find a pin connected to the ground plane.

![Finding the ground UART pin](/images/reveng-uart-busside-1.jpg)


Transmit (TX) pin:

* Transmit (TX) pin. Oscilloscope to pin under test, boot device, if seeing square waves, likely TX pin.
* Option 2. Measure DC voltage. If fluctuating probably sending data.
* Option 3. Bus pirate brute force. Enter UART mode on bus pirate with `m` option. Then activate transparent bridge mode with the `(1)` macro. Try each pin. Rebooting embedded device each time. If you see data, its probably TX. Now tune in the correct baud rate. Enter UART mode with the `m` option, and try some common settings 9600, 19200, 38400, 57600, 115200, all 8N1.


Receive (RX) pin:

* Brute force. Connect each pin. Type something, does it echo back?

#### BusSide Example

Before running the busside client (from the BusSide git repo) make sure you install `pyserial`:

    sudo python -m pip install pyserial
    sudo python ./busside.py /dev/ttyUSB0

Also, if running a system with both python 2 and 3, make sure you bind `alternatives` to use version 2.x. As per the BUSSide wiki, get a lay of the land with an `auto` probe:

    > uart passthrough auto
    +++ Sending UART discovery rx command
    +++ Connecting to the BUSSIde
    +++ GPIO 1 has 0 signal changes
    +++ GPIO 2 has 0 signal changes
    +++ GPIO 3 has 0 signal changes
    +++ GPIO 4 has 0 signal changes
    +++ GPIO 5 has 0 signal changes
    +++ GPIO 6 has 0 signal changes
    +++ GPIO 7 has 854 signal changes
    +++ UART FOUND
    +++ DATABITS: 8
    +++ STOPBITS: 1
    +++ PARITY: NONE
    +++ BAUDRATE: 115200
    +++ GPIO 8 has 0 signal changes
    +++ GPIO 9 has 0 signal changes
    +++ SUCCESS

Success, the RX (the TX pin on device) was discovered on GPIO pin 7, with a baud rate of 115200. Lastly we need to get TX working by figuring out which UART pin is RX.

    > uart discover tx 7 115200
    +++ Sending UART discovery tx command
    +++ Connecting to the BUSSIde
    +++ FOUND UART TX on GPIO 6
    +++ SUCCESS

Found it, was the pin connected to GPIO 6. With both TX/RX we have bi-directional communication in place. Activating pasthrough mode will hopefully now give us a root shell:

    > uart passthrough 7 6 115200
    +++ Connecting to the BUSSIde
    +++ Entering passthrough mode

    / $ ls
    bin      etc      linuxrc  pool     root     sys      usr      wps
    dev      lib      mnt      proc     sbin     tmp      var
    
    $ cat /proc/cpuinfo 
    system type		: RTL8676S
    processor		: 0
    cpu model		: 56321
    BogoMIPS		: 448.92
    tlb_entries		: 64
    mips16 implemented	: yes
    /proc $ cat /proc/cpuinfo 
    system type		: RTL8676S
    processor		: 0
    cpu model		: 56321
    BogoMIPS		: 448.92
    tlb_entries		: 64
    mips16 implemented	: yes





#### BusPrirate Example

    root@kali:~# sudo minicom -D /dev/ttyUSB0
    
    Welcome to minicom 2.7.1
    
    OPTIONS: I18n
    Compiled on Aug 13 2017, 15:25:34.
    Port /dev/ttyUSB0, 23:26:20
    
    Press CTRL-A Z for help on special keys
    
    111111(1)
    
    HiZ>m
    1. HiZ
    2. 1-WIRE
    3. UART
    4. I2C
    5. SPI
    6. 2WIRE
    7. 3WIRE
    8. LCD
    9. DIO
    x. exit(without change)
    
    m
    1. HiZ
    2. 1-WIRE
    3. UART
    4. I2C
    5. SPI
    6. 2WIRE
    7. 3WIRE
    8. LCD
    9. DIO
    x. exit(without change)
    
    (1)>3
    Set serial port speed: (bps)
     1. 300
     2. 1200
     3. 2400
     4. 4800
     5. 9600
     6. 19200
     7. 38400
     8. 57600
     9. 115200
    10. BRG raw value
    
    (1)>7
    Data bits and parity:
     1. 8, NONE *default 
     2. 8, EVEN 
     3. 8, ODD 
     4. 9, NONE
    (1)>1
    Stop bits:
     1. 1 *default
     2. 2
    (1)>1
    Receive polarity:
     1. Idle 1 *default
     2. Idle 0
    (1)>1
    Select output type:
     1. Open drain (H=Hi-Z, L=GND)
     2. Normal (H=3.3V, L=GND)
    
    (1)>1
    Ready
    UART>(1)
    UART bridge
    Reset to exit
    Are you sure? y
    
    # 
    # echo hello
    hello
    # ls
    bin      etc      proc     usr      var.tar
    dev      lib      sbin     var
    
    CTRL-A Z for help | 115200 8N1 | NOR | Minicom 2.7.1 | VT102 | Offline | ttyUSB0 




# Resources


## Reading


* [Sniffing Keystrokes with Lasers and Voltmeters by Andrea "lcars" Barisani and Daniele "danbia" Bianco](#TODO)
* [BitBlaze: A New Approach to Computer Security via Binary Analysis](#TODO)
* [Smashing the Stack for Fun and Profit by Aleph One](#TODO)



## Presentations

[TODO Find defcon link](). Checkout `sandsifter` for auditing the CPU and instruction sets it actually supports. From defcon presentation `github.com/xoreaxeaxeax`, on auditing CPU instruction sets. Works from ring 3.

[Are all BSD's are created equally: A survey of the BSD kernel]()

[The Tao of Hardware the Te of Implants]()


