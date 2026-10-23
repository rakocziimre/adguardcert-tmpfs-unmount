#!/system/bin/sh
# Unmounts the leftover adguardcert staging tmpfs after boot.
# The certificate bind mount over /apex/com.android.conscrypt/cacerts is a
# separate mount and stays in place, so HTTPS filtering keeps working.

TARGET=/data/local/tmp/adg-ca-copy
LOG=/data/local/tmp/adg-unmount.log

while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 2
done
sleep 10

{
  echo "== $(date)"
  for pid in 1 $(pidof zygote zygote64); do
    if grep -q " $TARGET " "/proc/$pid/mountinfo" 2>/dev/null; then
      echo "pid $pid: mount found, unmounting"
      nsenter --mount="/proc/$pid/ns/mnt" -- /bin/umount -l "$TARGET" 2>&1
    else
      echo "pid $pid: no mount"
    fi
  done
} >> "$LOG" 2>&1
