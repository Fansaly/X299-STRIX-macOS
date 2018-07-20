// Apple NVMe Controller
// PCI0.RP09.PXSX => PCI0.RP09.ANS1

#ifndef NO_DEFINITIONBLOCK
DefinitionBlock("", "SSDT", 2, "hack", "_ANSC", 0)
{
#endif
    External (_SB_.PCI0.RP09, DeviceObj)    // (from opcode)
    External (_SB_.PCI0.RP09.PXSX, DeviceObj)    // (from opcode)
    External (DTGP, MethodObj)    // 5 Arguments (from opcode)

    Scope (\_SB.PCI0.RP09)
    {
        Scope (PXSX)
        {
            Name (_STA, Zero)  // _STA: Status
        }

        Device (ANS1)
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

                Store (Package (0x08)
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
                        Buffer (0x15)
                        {
                            "Apple SSD Controller"
                        },

                        "model",
                        Buffer (0x12)
                        {
                            "Apple SSD AP1024M"
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
