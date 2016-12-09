#!/bin/bash - 
#===============================================================================
#
#          FILE: dopackage.sh
# 
#         USAGE: ./dopackage.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: jq
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: FPI 
#  ORGANIZATION: STMicroelectronics
#     COPYRIGHT: Copyright (C) 2016, STMicroelectronics - All Rights Reserved
#       CREATED: 12/06/16 13:57
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

TOPDIR=../
PKGDIR=${TOPDIR}/packages
TOOLSDIR=${TOPDIR}/tools

jsonFile="package_stub_stm_index.json"
pkgver="1.0"
url="http://github.com/fpistm/boardManagerStub/raw/master/STM32"

sum=0
size=0

###############################################################################
## Help function
usage()
{
    echo "############################################################"
    echo "##"
    echo "##  `basename $0`"
    echo "##"
    echo "############################################################"
    echo "##"
    echo "## `basename $0`"
    echo "## [-h] [-v <package version>]"
    echo "##"
    echo "## Optionnal:"
    echo "##"
    echo "## -h: print this help"
    echo "##"
    echo "## -v: specify package version (default: $pkgver)"
    echo "##"
    echo "############################################################"
    exit 0
}

main(){
    echo "stub"
}

sumSizeOf()
{
  sum=`sha256sum $1| cut -d' ' -f1`
  size=`stat --printf="%s" $1`
}

###############################################################################
# FUNCTION MAIN
###############################################################################
# parse command line arguments
# options may be followed by one colon to indicate they have a required arg
options=`getopt -o hv: -- "$@"`

if [ $? != 0 ] ; then usage; exit 1 ; fi

eval set -- "$options"

while true ; do
	case "$1" in
	-h|-\?) usage
        shift;;
	-v) pkgver=$2
        shift 2;;
	--) shift;
        break;;
    *) break;;
    esac
done

#Check if jq is available
jq --version 2>/dev/null
if [ $? -ne 0 ]; then
  echo "jq is required to update the json file."
  echo "Please, install it."
  exit 1
fi

echo "Creating packages version $pkgver ..."
stubFile="STM32Stub-${pkgver}.tar.bz2"
toolsFile="STM32Tools-${pkgver}.tar.bz2"

tar -jcf ${PKGDIR}/$stubFile STM32Stub/
if [ $? -ne 0 ]; then
  echo "failed to create archive $stubFile"
  exit 2
fi

tar -jcf ${TOOLSDIR}/$toolsFile STM32Tools/
if [ $? -ne 0 ]; then
  echo "failed to create archive $toolsFile"
  exit 3
fi
echo "done"

echo "Updating json file..."
#ex:
#(.packages[] | .platforms[] | select(.name == "STM32 Stub Board")  .version) = "3.0" 
#(.packages[] | .platforms[] |   .version) = "3.0" 
#.packages[].platforms[].version = "3.0" 
sumSizeOf "${PKGDIR}/$stubFile"
  
jq '.packages[].platforms[].version= "'${pkgver}'" |
    .packages[].platforms[].archiveFileName= "'${stubFile}'" |
    .packages[].platforms[].url= "'${url}/packages/${stubFile}'" |
    .packages[].platforms[].checksum= "SHA-256:'${sum}'" |
    .packages[].platforms[].size= "'${size}'"
   ' ${TOPDIR}/$jsonFile > ${jsonFile}.tmp
if [ $? -ne 0 ]; then
  echo "failed to update $jsonFile"
  rm -f ${jsonFile}.tmp
  exit 4
fi

sumSizeOf "${TOOLSDIR}/$toolsFile"
jq '(.packages[].tools[] | select(.name == "STM32Tools").version)= "'${pkgver}'" |
    (.packages[].tools[] | select(.name == "STM32Tools").systems[].archiveFileName)= "'${toolsFile}'" |
    (.packages[].tools[] | select(.name == "STM32Tools").systems[].url)= "'${url}/tools/${toolsFile}'" |
    (.packages[].tools[] | select(.name == "STM32Tools").systems[].checksum)= "SHA-256:'${sum}'" |
    (.packages[].tools[] | select(.name == "STM32Tools").systems[].size)= "'${size}'"
   ' ${jsonFile}.tmp > ${jsonFile}.tmp2

if [ $? -ne 0 ]; then
  echo "failed to update $jsonFile"
  rm -f ${jsonFile}.tmp ${jsonFile}.tmp2
  exit 5
fi

mv ${jsonFile}.tmp2 ${TOPDIR}/${jsonFile}
rm -f ${jsonFile}.tmp

echo "done" 

