// Nvidia Graphics Card and HDMI/DP Audio
// SL05 => PEGP
// PEGP => GFX0

#ifndef NO_DEFINITIONBLOCK
DefinitionBlock("", "SSDT", 2, "hack", "_HDAU", 0)
{
#endif
    External (_SB_.PC02.BR2A, DeviceObj)    // (from opcode)
    External (_SB_.PC02.BR2A.SL05, DeviceObj)    // (from opcode)
    External (_SB_.PC02.BR2A.PEGP, DeviceObj)    // (from opcode)
    External (DTGP, MethodObj)    // 5 Arguments (from opcode)

    Scope (_SB.PC02.BR2A)
    {
        Scope (SL05)
        {
            Name (_STA, Zero)  // _STA: Status
        }

        Scope (PEGP)
        {
            Name (_STA, Zero)  // _STA: Status
        }

        Device (GFX0)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x14)
                    {
                        "built-in",
                        Buffer (One)
                        {
                             0x00
                        },

                        "device-id",
                        Buffer (0x04)
                        {
                             0x80, 0x1B, 0x00, 0x00
                        },

                        "hda-gfx",
                        Buffer (0x0A)
                        {
                            "onboard-2"
                        },

                        "AAPL,slot-name",
                        Buffer (0x07)
                        {
                            "Slot-1"
                        },

                        "@0,connector-type",
                        Buffer (0x04)
                        {
                             0x00, 0x08, 0x00, 0x00
                        },

                        "@1,connector-type",
                        Buffer (0x04)
                        {
                             0x00, 0x08, 0x00, 0x00
                        },

                        "@2,connector-type",
                        Buffer (0x04)
                        {
                             0x00, 0x08, 0x00, 0x00
                        },

                        "@3,connector-type",
                        Buffer (0x04)
                        {
                             0x00, 0x08, 0x00, 0x00
                        },

                        "@4,connector-type",
                        Buffer (0x04)
                        {
                             0x00, 0x08, 0x00, 0x00
                        },

                        "@5,connector-type",
                        Buffer (0x04)
                        {
                             0x00, 0x08, 0x00, 0x00
                        }
                    }, Local0)
                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                Return (Local0)
            }
        }

        Device (HDAU)
        {
            Name (_ADR, One)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x0C)
                    {
                        "built-in",
                        Buffer (One)
                        {
                             0x00
                        },

                        "device-id",
                        Buffer (0x04)
                        {
                             0xF0, 0x10, 0x00, 0x00
                        },

                        "AAPL,slot-name",
                        Buffer (0x07)
                        {
                            "Slot-1"
                        },

                        "device_type",
                        Buffer (0x16)
                        {
                            "Multimedia Controller"
                        },

                        "name",
                        Buffer (0x1D)
                        {
                            "NVIDIA High Definition Audio"
                        },

                        "hda-gfx",
                        Buffer (0x0A)
                        {
                            "onboard-2"
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
