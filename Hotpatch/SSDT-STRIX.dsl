// Custom configuration for
// ROG STRIX X299-E GAMING

DefinitionBlock("", "SSDT", 2, "hack", "_STRIX", 0)
{
    #define NO_DEFINITIONBLOCK
    #include "Downloads/SSDT-XOSI.dsl"
    #include "SSDT-DTGP.dsl"

    #include "SSDT-HDEF.dsl"
    #include "SSDT-HDAU.dsl"

    #include "SSDT-PMCR.dsl"
    #include "SSDT-THSS.dsl"

    #include "SSDT-USBX.dsl"
    #include "SSDT-XHCI.dsl"
    #include "SSDT-XHCX.dsl"

    #include "SSDT-ANSC.dsl"
    #include "SSDT-SATA.dsl"

    #include "SSDT-LANC.dsl"
}
//EOF
