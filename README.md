# AdGuard tmpfs unmount

A tiny KernelSU module that removes the leftover `/data/local/tmp/adg-ca-copy` tmpfs mount created by the [adguardcert](https://github.com/AdguardTeam/adguardcert) module.

## The problem

On Android 14+, the adguardcert module installs AdGuard's CA certificate into the system trust store by:

1. mounting a temporary tmpfs at `/data/local/tmp/adg-ca-copy`,
2. copying the certificates into it,
3. bind-mounting that directory over `/apex/com.android.conscrypt/cacerts`,
4. unmounting the temporary tmpfs again.

On some setups the tmpfs stays visible to apps afterwards. Root/environment checkers such as [Duck Detector](https://github.com/eltavine/Duck-Detector-Refactoring) then report it in their Mount card, for example as **"Shell tmp dedicated mount: tmpfs, target=/data/local/tmp/adg-ca-copy"**.

## What this module does

After boot completes, it checks the init and zygote mount namespaces and unmounts `/data/local/tmp/adg-ca-copy` wherever it is still mounted (`umount -l`).

The certificate bind mount over `/apex/com.android.conscrypt/cacerts` is a separate mount and is **not** touched, so AdGuard's HTTPS filtering keeps working.

## Requirements

- KernelSU (or a compatible fork) with module support
- The adguardcert module installed

## Installation

1. Download `adg_unmount_tmpfs.zip` from the **Releases** page.
2. Open the KernelSU manager, go to **Modules**, and install the zip from storage.
3. Reboot.

## Checking that it works

The module writes a log to `/data/local/tmp/adg-unmount.log`:

```
su -c "cat /data/local/tmp/adg-unmount.log"
```

For each namespace it logs either `mount found, unmounting` or `no mount`.

To see whether the mount is gone from the app's point of view, run your checker again after a reboot (Duck Detector: the **Mount** card, "Shell tmp view").

## Uninstall

Remove the module in the KernelSU manager and reboot. You can delete `/data/local/tmp/adg-unmount.log` afterwards.

## Limitations

- It only removes the temporary tmpfs. The certificate bind mount over the APEX path is still a mount, and other checks may flag it.
- Apps launched before the cleanup ran keep their old mount view until they are restarted.
- This does not hide root, KernelSU, or any other module.

## Tested on

- Samsung Galaxy A52s 5G (SM-A528B), UN1CA ROM, Android 16
- KernelSU manager v3.3.0 with the MCK_20261003_KSU_a52sxq kernel
- adguardcert v2.1

Other setups are untested. Reports are welcome.

## Disclaimer

Use at your own risk. The module runs a short shell script as root at boot, and the only thing it does is `umount -l` on one path. It is not affiliated with AdGuard, KernelSU or Duck Detector.

## Author

Rakoczi
