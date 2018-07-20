// ASMedia ASM2142 USB 3.1 Controller
// PCI0.RP05.PXSX => PCI0.RP05.XHC2
// PCI0.RP07.PXSX => PCI0.RP07.XHC3

#ifndef NO_DEFINITIONBLOCK
DefinitionBlock("", "SSDT", 2, "hack", "_XHCX", 0)
{
#endif
    External (_SB_.PCI0.RP05, DeviceObj)    // (from opcode)
    External (_SB_.PCI0.RP05.PXSX, DeviceObj)    // (from opcode)
    External (_SB_.PCI0.RP07, DeviceObj)    // (from opcode)
    External (_SB_.PCI0.RP07.PXSX, DeviceObj)    // (from opcode)
    External (DTGP, MethodObj)    // 5 Arguments (from opcode)

    Scope (\_SB.PCI0.RP05)
    {
        Scope (PXSX)
        {
            Name (_STA, Zero)  // _STA: Status
        }

        Device (XHC2)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (LEqual (Arg2, Zero))
                {
                    Return (Buffer (One)
                    {
                         0x03
                    })
                }

                Store (Package (0x1B)
                    {
                        "AAPL,slot-name",
                        Buffer (0x09)
                        {
                            "Built In"
                        },

                        "built-in",
                        Buffer (One)
                        {
                             0x00
                        },

                        "device-id",
                        Buffer (0x04)
                        {
                             0x42, 0x21, 0x00, 0x00
                        },

                        "name",
                        Buffer (0x17)
                        {
                            "ASMedia XHC Controller"
                        },

                        "model",
                        Buffer (0x2E)
                        {
                            "ASMedia ASM2142 #1 1x USB 3.1 Type-C External"
                        },

                        "AAPL,current-available",
                        0x0834,
                        "AAPL,current-extra",
                        0x0A8C,
                        "AAPL,current-in-sleep",
                        0x0A8C,
                        "AAPL,max-port-current-in-sleep",
                        0x0834,
                        "AAPL,device-internal",
                        Zero,
                        "AAPL,clock-id",
                        Buffer (One)
                        {
                             0x01
                        },

                        "AAPL,root-hub-depth",
                        0x1A,
                        "AAPL,XHC-clock-id",
                        One,
                        Buffer (One)
                        {
                             0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }
    }

    Scope (\_SB.PCI0.RP07)
    {
        Scope (PXSX)
        {
            Name (_STA, Zero)  // _STA: Status
        }

        Device (XHC3)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (LEqual (Arg2, 0x00020000))
                {
                    Return (Buffer (One)
                    {
                         0x03
                    })
                }

                Store (Package (0x1B)
                    {
                        "AAPL,slot-name",
                        Buffer (0x09)
                        {
                            "Built In"
                        },

                        "built-in",
                        Buffer (One)
                        {
                             0x00
                        },

                        "device-id",
                        Buffer (0x04)
                        {
                             0x42, 0x21, 0x00, 0x00
                        },

                        "name",
                        Buffer (0x17)
                        {
                            "ASMedia XHC Controller"
                        },

                        "model",
                        Buffer (0x2E)
                        {
                            "ASMedia ASM2142 #2 3x USB 3.1 Type-A External"
                        },

                        "AAPL,current-available",
                        0x0834,
                        "AAPL,current-extra",
                        0x0A8C,
                        "AAPL,current-in-sleep",
                        0x0A8C,
                        "AAPL,max-port-current-in-sleep",
                        0x0834,
                        "AAPL,device-internal",
                        Zero,
                        "AAPL,clock-id",
                        Buffer (One)
                        {
                             0x01
                        },

                        "AAPL,root-hub-depth",
                        0x1A,
                        "AAPL,XHC-clock-id",
                        One,
                        Buffer (One)
                        {
                             0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }
    }
#ifndef NO_DEFINITIONBLOCK
}
#endif
//EOF
