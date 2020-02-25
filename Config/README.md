Refer to the following usage and `config.template.plist` to configure the appropriate `config.plist`.

### Tools
```xml
<key>Tools</key>
<dict>
  <key>Bitbucket</key>
  <array>
    <dict>
      <key>Author</key>
      <string>RehabMan</string>
      <key>Repo</key>
      <string>os-x-maciasl-patchmatic</string>
      <key>Name</key>
      <string>RehabMan-patchmatic</string>
      <key>Installations</key>
      <array>...</array>
    </dict>
  </array>
</dict>
```
| Name   | Type     | Requirement | Description |
| :--    | :--      | :--         | :-- |
| Author | `string` | yes         | Remote repo owner. |
| Repo   | `string` | yes         | Remote repo name. |
| Name   | `string` | optional    | Wildcard of download file name. |
| Installations | `array` | no    | |


### Hotpatch
```xml
<key>Hotpatch</key>
<dict>
  <key>Author</key>
  <string>RehabMan</string>
  <key>Repo</key>
  <string>OS-X-Clover-Laptop-Config</string>
  <key>Path</key>
  <string>hotpatch</string>
  <key>SSDT</key>
  <array>
    <string>SSDT-XCPM.dsl</string>
    ...
  </array>
</dict>
```
| Name   | Type     | Requirement | Description |
| :--    | :--      | :--         | :-- |
| Author | `string` | yes         | Remote repo owner. |
| Repo   | `string` | yes         | Remote repo name. |
| Path   | `string` | optional    | SSDT file location. |
| SSDT   | `array`  | yes         | Group of SSDT files. |

### Kexts
```xml
<key>Kexts</key>
<dict>
  <key>Install</key>
  <dict>
    <key>GitHub</key>
    <array>
      <dict>
        <key>Author</key>
        <string>acidanthera</string>
        <key>Repo</key>
        <string>BrcmPatchRAM</string>
        <key>Installations</key>
        <array>
          <dict>
            <key>Name</key>
            <string>BrcmPatchRAM3.kext</string>
          </dict>
          <dict>
            <key>Name</key>
            <string>BrcmFirmwareRepo.kext</string>
            <key>Essential</key>
            <true/>
          </dict>
          <dict>
            <key>Name</key>
            <string>BrcmBluetoothInjector.kext</string>
          </dict>
          <dict>
            <key>Name</key>
            <string>BrcmNonPatchRAM2.kext</string>
          </dict>
        </array>
      </dict>
    </array>
    <key>Bitbucket</key>
    <array>...</array>
    <key>Local</key>
    <array>
      <dict>
        <key>Author</key>
        <string>interferenc</string>
        <key>Repo</key>
        <string>TSCAdjustReset</string>
        <key>Repo-type</key>
        <string>GitHub</string>
        <key>Installations</key>
        <array>...</array>
      </dict>
    </array>
  </dict>
  <key>Deprecated</key>
  <array/>
</dict>
```
| Name          | Type         | Requirement | Description |
| :--           | :--          | :--         | :-- |
| Install       | `dictionary` | yes         | Kexts to install. |
| Deprecated    | `array`      | no          | Kexts to remove. |
| &nbsp; | &nbsp; | &nbsp; | &nbsp; |
| GitHub        | `array`      | optional    | Kexts of GitHub. |
| Bitbucket     | `array`      | optional    | Kexts of Bitbucket. |
| Local         | `array`      | optional    | Kexts of Local. <br/> `Author` `Repo` `Repo-type` is just for tagging, you can use any value you like. |
| &nbsp; | &nbsp; | &nbsp; | &nbsp; |
| Author        | `string`     | yes         | Remote repo owner. |
| Repo          | `string`     | yes         | Remote repo name. |
| Installations | `array`      | yes         | |
| &nbsp; | &nbsp; | &nbsp; | &nbsp; |
| Name          | `string`     | yes         | Kext name to install. |
| Essential     | `boolean`    | optional    | If `true`, install kext to `/L/E` of system. |

### Drivers
> No `Essential`, other reference **Kexts** section.
