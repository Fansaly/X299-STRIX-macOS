// When using the XHCI device name for USB,
// one observes a bunch of USB Power Errors when booting the system.
// The USBX PCI device implementation fixes this errors.

#ifndef NO_DEFINITIONBLOCK
DefinitionBlock("", "SSDT", 2, "hack", "_USBX", 0)
{
#endif
    Device (_SB.USBX)
    {
        Name (_ADR, Zero)  // _ADR: Address
        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            If (LNot (Arg2))
            {
                Return (Buffer (One)
                {
                     0x03
                })
            }

            Return (Package (0x08)
            {
                "kUSBSleepPortCurrentLimit",
                0x0834,
                "kUSBSleepPowerSupply",
                0x13EC,
                "kUSBWakePortCurrentLimit",
                0x0834,
                "kUSBWakePowerSupply",
                0x13EC
            })
        }
    }
#ifndef NO_DEFINITIONBLOCK
}
#endif
//EOF
