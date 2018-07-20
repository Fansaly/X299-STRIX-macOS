// Intel AHCI SATA Controller

#ifndef NO_DEFINITIONBLOCK
DefinitionBlock("", "SSDT", 2, "hack", "_SATA", 0)
{
#endif
    External (_SB_.PCI0, DeviceObj)    // (from opcode)
    External (_SB_.PCI0.SAT1, DeviceObj)    // (from opcode)
    External (DTGP, MethodObj)    // 5 Arguments (from opcode)

    Scope (\_SB.PCI0)
    {
        Scope (SAT1)
        {
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                Store (Package (0x0C)
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
                            "Intel AHCI Controller"
                        },

                        "model",
                        Buffer (0x1F)
                        {
                            "Intel X299 Series Chipset SATA"
                        },

                        "device_type",
                        Buffer (0x15)
                        {
                            "AHCI SATA Controller"
                        },

                        "device-id",
                        Buffer (0x04)
                        {
                             0x82, 0xA2, 0x00, 0x00
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
