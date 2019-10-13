// onboard Extended Host Controller Interface (XHCI)

#ifndef NO_DEFINITIONBLOCK
DefinitionBlock("", "SSDT", 2, "hack", "_XHCI", 0)
{
#endif
    External (_SB_.PCI0.XHCI, DeviceObj)
    External (DTGP, MethodObj)    // 5 Arguments

    Scope (\_SB.PCI0.XHCI)
    {
        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
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
                         0xAF, 0xA2, 0x00, 0x00
                    },

                    "name",
                    Buffer (0x2B)
                    {
                        "Intel X299 Series Chipset XHCI Controller"
                    },

                    "model",
                    Buffer (0x22)
                    {
                        "Intel X299 Series Chipset USB 3.0"
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
#ifndef NO_DEFINITIONBLOCK
}
#endif
//EOF
