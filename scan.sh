#!/bin/bash

touch scan_out.txt
if [ ! -f /tmp/filelist.txt ]; then
  find / -not \( -path /Volumes -prune \) -not \( -path /System/Volumes -prune \) -type f -perm +111 > /tmp/filelist.txt
  #find /Volumes/HOMER -type f -perm +111 > /tmp/filelist.txt
fi

for exec in `cat /tmp/filelist.txt`; do
  echo -n '.'

  #check for mach-o binaries
  file $exec | grep -q "Mach-O" 
  if [[ $? == 1 ]]; then
    continue;
  fi

  SIGN=`codesign -dvvv $exec 2>&1`
  VALID=$?

  #Check for valid signatures from known good entities
  if [[ $VALID == 0 ]]; then
    if (echo $SIGN | grep -q 'Authority=Apple Code Signing Certification Authority') ||
      (echo $SIGN | grep -q 'Authority=Developer ID Application: Google LLC (EQHXZ8M8AV)') ||
      (echo $SIGN | grep -q 'Authority=Developer ID Application: Microsoft Corporation (UBF8T346G9)') ||
      (echo $SIGN | grep -q 'Authority=Developer ID Application: Adobe Systems, Inc. (JQ525L2MZD)') ||
      (echo $SIGN | grep -q 'Authority=Developer ID Application: Skype Communications S.a.r.l (AL799K98FX)') ||
      (echo $SIGN | grep -q 'Authority=Developer ID Application: WhatsApp Inc. (57T9237FN3)') || 
      (echo $SIGN | grep -q 'Authority=Developer ID Application: Zoom Video Communications, Inc. (BJ4HAAB9B3)') ; then
        continue;
    fi
  fi

  echo -e "\n$exec: saving signature"
  echo "%%%%" >> scan_out.txt
  if [[ $VALID == 1 ]]; then
    echo "$exec: SIGNATURE INVALID"
    echo "$exec: SIGNATURE INVALID" >> scan_out.txt
  fi

  echo "$SIGN" >> scan_out.txt
done
