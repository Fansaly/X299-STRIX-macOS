// onboard Power Management Controller (PMC)
// PMC1 => PMCR

#ifndef NO_DEFINITIONBLOCK
DefinitionBlock("", "SSDT", 2, "hack", "_PMCR", 0)
{
#endif
    External (_SB_.PCI0, DeviceObj)    // (from opcode)
    External (_SB_.PCI0.PMC1, DeviceObj)    // (from opcode)
    External (_SB_.PCI0.PMCR, DeviceObj)    // (from opcode)
    External (DTGP, MethodObj)    // 5 Arguments (from opcode)

    Scope (\_SB.PCI0)
    {
        Scope (PMC1)
        {
            Name (_STA, Zero)  // _STA: Status
        }

        Device (PMCR)
        {
            Name (_ADR, 0x001F0002)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x0E)
                    {
                        "AAPL,slot-name",
                        Buffer (0x09)
                        {
                            "Built In"
                        },

                        "model",
                        Buffer (0x1E)
                        {
                            "Intel X299 Series Chipset PMC"
                        },

                        "name",
                        Buffer (0x0A)
                        {
                            "Intel PMC"
                        },

                        "device-id",
                        Buffer (0x04)
                        {
                             0xA1, 0xA2, 0x00, 0x00
                        },

                        "device_type",
                        Buffer (0x0F)
                        {
                            "PMC-Controller"
                        },

                        "built-in",
                        Buffer (One)
                        {
                             0x00
                        },

                        "compatible",
                        Buffer (0x0D)
                        {
                            "pci8086,a2a1"
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
