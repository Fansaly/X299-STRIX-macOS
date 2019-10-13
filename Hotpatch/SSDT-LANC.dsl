// onboard LAN Controller
// PCI0.GBE1 => PCI0.ETH0

#ifndef NO_DEFINITIONBLOCK
DefinitionBlock("", "SSDT", 2, "hack", "_LANC", 0)
{
#endif
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.GBE1, DeviceObj)
    External (DTGP, MethodObj)    // 5 Arguments

    Scope (\_SB.PCI0)
    {
        Scope (GBE1)
        {
            Name (_STA, Zero)  // _STA: Status
        }

        Device (ETH0)
        {
            Name (_ADR, 0x001F0006)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x10)
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

                        "name",
                        Buffer (0x16)
                        {
                            "Intel I219V2 Ethernet"
                        },

                        "model",
                        Buffer (0x2A)
                        {
                            "Intel I219V2 PCI Express Gigabit Ethernet"
                        },

                        "location",
                        Buffer (0x02)
                        {
                            "2"
                        },

                        "subsystem-id",
                        Buffer (0x04)
                        {
                             0x72, 0x86, 0x00, 0x00
                        },

                        "device-id",
                        Buffer (0x04)
                        {
                             0xB8, 0x15, 0x00, 0x00
                        },

                        "subsystem-vendor-id",
                        Buffer (0x04)
                        {
                             0x43, 0x10, 0x00, 0x00
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
