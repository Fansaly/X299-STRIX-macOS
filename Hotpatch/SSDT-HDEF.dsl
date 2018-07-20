// onboard Audio Controller
// CAVS => HDEF

#ifndef NO_DEFINITIONBLOCK
DefinitionBlock("", "SSDT", 2, "hack", "_HDEF", 0)
{
#endif
    External (_SB_.PCI0, DeviceObj)    // (from opcode)
    External (_SB_.PCI0.CAVS, DeviceObj)    // (from opcode)

    Scope (\_SB.PCI0)
    {
        Scope (CAVS)
        {
            Name (_STA, Zero)  // _STA: Status
        }

        Device (HDEF)
        {
            Name (_ADR, 0x001F0003)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x16)
                    {
                        "AAPL,slot-name",
                        Buffer (0x09)
                        {
                            "Built In"
                        },

                        "model",
                        Buffer (0x1C)
                        {
                            "Realtek ALC S1220A HD Audio"
                        },

                        "name",
                        Buffer (0x27)
                        {
                            "Realtek ALC S1220A HD Audio Controller"
                        },

                        "hda-gfx",
                        Buffer (0x0A)
                        {
                            "onboard-1"
                        },

                        "device_type",
                        Buffer (0x14)
                        {
                            "HD-Audio-Controller"
                        },

                        "device-id",
                        Buffer (0x04)
                        {
                             0xF0, 0xA2, 0x00, 0x00
                        },

                        "compatible",
                        Buffer (0x0D)
                        {
                            "pci8086,0C0C"
                        },

                        "MaximumBootBeepVolume",
                        Buffer (One)
                        {
                             0xEE
                        },

                        "MaximumBootBeepVolumeAlt",
                        Buffer (One)
                        {
                             0xEE
                        },

                        "layout-id",
                        Buffer (0x04)
                        {
                             0x07, 0x00, 0x00, 0x00
                        },

                        "PinConfigurations",
                        Buffer (Zero) {}
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
