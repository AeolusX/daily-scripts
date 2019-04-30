#!/bin/bash


Check(){
     if [ $((UID)) -ne 0 ]; then
        exit 1
    fi
}

Usage(){
    echo ""
    echo "Usage :`basename $0` -s [src] -d [dst]"
    echo "REPLACE Example: bash replace_vendor.sh -s /src_dir -d /dst_dir"
    echo "ROLLBACK EXample: bash replace_vendor.sh -r vendor-[timestamp]"
    echo ""
    exit 0
}

Replace(){
    src=`file_remove_slash $src`
    dst=`file_remove_slash $dst`
    if [[ -d ${src}/vendor && -d ${dst}/vendor ]]; then
	timestamp=$(date +%s)
	/bin/mv ${dst}/vendor ${dst}/vendor-${timestamp} && /bin/cp -a ${src}/vendor ${dst}/vendor && chown www:www ${dst}/vendor -R
	if [ $? = 0 ]; then
	    echo -e "\033[1;36;40m REPLACE vendor SUCCESS! \033[0m"
	    echo -e "\033[1;36;40m If you need ROLLBACk vendor, you can run: \033[0m"
	    echo -e "\033[1;36;40m bash replace_vendor.sh -d $dst -r vendor-${timestamp} \033[0m"
	fi
    else
	echo -e "\033[1;31;40m Directory doesn't exist, please check.\033[0m"
    fi
}

Rollback(){
    dst=`file_remove_slash $dst`
    if [ -d ${dst}/${rbk} ]; then
        /bin/mv ${dst}/vendor ${dst}/vendor-err && /bin/mv ${dst}/${rbk} ${dst}/vendor
        if [ $? = 0 ]; then
            echo -e "\033[1;36;40m ROLLBACK vendor SUCCESS! \033[0m"
            echo -e "\033[1;36;40m There is vendor-err in $dst \033[0m"
            echo -e "\033[1;36;40m If you confirm there is sth wrong, you can delete it. \033[0m"
        fi
    else
	echo -e "\033[1;31;40m ${dst}/${rbk} doesn't exist. \033[0m"
    fi
}

#remove dir path end /
function file_remove_slash()
{
local FILE_NAME="$1"
NEW_FILE=`echo $FILE_NAME | sed 's#/$##g'`
echo $NEW_FILE
}


while getopts s:d:r:h OPTION
do
case $OPTION in
        s)src=$OPTARG
        ;;
        d)dst=$OPTARG
        ;;
	r)rbk=$OPTARG
	;;
        h)Usage
        ;;
        ?)Usage
        ;;
esac
done

if [[ -n $src && -n $dst && ! -n $rbk ]]; then
    Replace
elif [[ ! -n $src && -n $dst && -n $rbk ]]; then
    Rollback
else
    Usage
fi

