#!/usr/bin/ksh
IFS='
'
HOST=$(hostname -s)
CAPITALHOST=$(echo "$HOST" |awk '{print toupper($0)}')
echo "---------------------------------------------------"
echo "       $CAPITALHOST DISK DRIVES INFORMATONS        "
echo "---------------------------------------------------"
echo "*** Fiber Channel :"
FCS=$(lsdev -Ccadapter| grep fcs| egrep -v 'Defined'| awk '{print $1}')
if [ -z "$FCS" ]; then
  echo "No FC adapters were found on this system thus no fiber device drives."
else
  for fcard in $FCS; do
  WWN=$(lscfg -vpl $fcard| grep Network| awk '{print $2}'| sed s'/Address..........//')
  echo "$fcard $WWN"
done
echo "---"
printf "%-8s %-9s %-18s %-5s %-10s %-15s %-8s %-12s\n" "DISK" "SIZE(GB)" "PVID" "LUN" "BAY" "VTD" "VHOST" "LPAR"
LSMAP=$(/usr/ios/cli/ioscli lsmap -all)
LSMAP_1=$(/usr/ios/cli/ioscli lsmap -all -fmt ":") 
  FCDISK=$(echo "$LSMAP" |awk '$1=="Backing" && $2=="device" {print $3}')
  for dsk in $FCDISK; do
    FPVID=$(lspv | grep -w $dsk | awk '{print $2}')
    FSIZE=$(getconf DISK_SIZE /dev/${dsk})
    FSIZE_GB=$(echo "scale=2; $FSIZE /1024" | bc)
    LUNID=$(lscfg -vl $dsk | grep Z1| awk '{print $2}'| sed 's/Specific.(Z1)........//')
    HEXBAY=$(lscfg -vl $dsk | grep Serial | awk '{print $3}')
    DECBAY=$(echo "ibase=16; $HEXBAY" | bc)
    VHOST=$(echo "$LSMAP_1"|awk -F: '/:'$dsk':/ {print $1}')
    LPAR_16=$(echo "$LSMAP_1"|awk -F: '$1=="'$VHOST'" {print $3}'|tail -c 3 |tr [a-z] [A-Z] )
    LPAR_10=$(echo "ibase=16;${LPAR_16}"|bc)
    LPAR_NAME=$(su - padmin -c "lssyscfg -r lpar --filter lpar_ids=${LPAR_10} -F name")
    VTD=$(echo "$LSMAP" |grep -wp $dsk |awk '$1=="VTD" {print $2}')
    if [ "$DECBAY" == "DecBay1" ]; then
      BAY=Bay1
    elif [ "$DECBAY" == "DecBay2" ]; then
      BAY=Bay2
    else
      BAY="UNKNOWN"
    fi
printf "%-8s %-9s %-18s %-5s %-10s %-15s %-8s %-12s\n" $dsk $FSIZE_GB $FPVID $LUNID $BAY $VTD $VHOST ${LPAR_NAME}
  done
fi
