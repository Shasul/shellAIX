#!/usr/bin/ksh93
IFS='
'
MKSYSDIR=/export/nim/vio_mksysb
VIOLIST=$(lsnim -t standalone| egrep '(vio)' | awk '{print $1}'| sort)
#VIOLIST=( $(lsnim -t standalone| egrep '(vio)' | awk '{print $1}'| sort) )
#for ((i = 0; i < "${#VIOLIST[@]}"; i++))
#do
#    if [[ "$(ssh -q padmin@${srv} lssyscfg -r sys)" = /[VIOSE01010003-0245]*/ ]]
#        then VIOLIST[$i]=''
#    fi
#done
#echo ${VIOLIST[@]}
for srv in ${VIOLIST}
do
    echo "\n"
    echo "-------------------------------------"
    echo ${srv}
    ssh -q padmin@${srv} lssyscfg -r sys >/dev/null 2>&1
    if [ $? != 0 ]
        then echo "VIO sous HMC";continue
    fi
    if ssh -q padmin@${srv} test -e "profile_${srv}"
        then 
#            BEFDATE=$(ssh -q padmin@${srv} "echo \"istat profile_${srv} | grep modified \"| oem_setup_env" | awk '{print $3,$5,$4,$NF}')
            ssh -q padmin@${srv} bkprofdata -o backup -f profile_${srv}
            if [ $? != 0 ]
                then echo "NOK : création du fichier de backup du profil sur le fichier échouée";continue
            fi
#           AFTDATE=$(ssh -q padmin@${srv} "echo \"istat profile_${srv} | grep modified \"| oem_setup_env" | awk '{print $3,$5,$4,$NF}')
#            if [ "${BEFDATE}" = "${AFTDATE}" ]
#            then
#                echo "NOK : création du fichier de backup du profil sur le fichier échouée";continue
#            fi
            scp -p padmin@$srv:profile_${srv} $MKSYSDIR/
            if [ $? != 0 ]
                then echo "NOK : transfert du fichier de backup du profile échoué";continue
            fi
        else
            ssh -q padmin@$srv bkprofdata -o backup -f profile_${srv}
            if [ $? != 0 ]
                then echo "NOK : création du fichier de backup du profil sur le fichier échouée";continue
            fi
            scp -p padmin@$srv:profile_${srv} $MKSYSDIR/
            if [ $? != 0 ]
                then echo "NOK : transfert du fichier de backup du profile échoué";continue
            fi
    fi
done
