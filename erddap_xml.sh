#!/bin/bash
#
#---Script to generate ERDDAP dataset xml files for all the .nc files in directories under <rootdir>.
#---Basename of the directories need to be gives as parameters to the script.
#---Folders need to be named as <dirbasename>_<indir_postfix>. 
#---Outputs go to directories named <dirbasename>_<outdir_postix>
#---outfile= output file containing all the ERDDAP xml files. 
# 
#  This script suits a situation where one needs to generate the XM Lsnippet for each .nc file separately.

### ~/Desktop/WinLin_Share/00-GCOOS/00-MBON/scripts/generate_dataset_xml

#-------------------------------------------------------------
# USER DEFINED DIRECTORIES FOR DATA AND ERDDAP BIGPARENTDIR
#-------------------------------------------------------------
# Data directory (data):
#rootdir=/home/tsaari-admin/Desktop/WinLin_Share/00-GCOOS/00-MBON/WaltonSmith/
rootdir=/data/erddap/Walton-Smith/
# ERDDAP GeneratDatasetsXml script location
erddap_scriptdir=/usr/local/apache-tomcat-10.1.7/webapps/erddap/WEB-INF/
# ERDDAP output directory for the generated XML files:
xmldir=/usr/local/erddap_bigparentdir/logs/
# optional suffix. Keep empty if you want to match data folder names exactly. 
#datadir_suffix=""
datadir_suffix="_Profile"

#outfile=GenerateDatasetsXml_WS22141.out

# NOTE: Bash command to rename folders (_nc suffic to _Profile suffix):
# for adir in `ls -d *nc`; do basename="${adir/%_nc}"; sudo mv $adir "${basename}_Profile";  done

# data directories to be looped through are to be given as cmd line arguments

for adir in $@
do
    # the XML otput file for the current folder (e.g. a cruise in case of Walton-Smith CTD data)
    outfile=GenerateDatasetsXml_${adir}.out
    # the current data input folder
    indir="${rootdir}${adir}${datadir_suffix}/"

    # start the loop thru files
    printf "<!--  Start $adir --> \n \n \n" > $xmldir$outfile
    # change to the directory and loop through .nc files
    cd $indir
    for ff in `ls *.nc`
    do
        echo $ff
        # change to erddap dir and run the XML generation script
        cd $erddap_scriptdir
        echo "CURRENT DIR:"
        pwd
        ${erddap_scriptdir}GenerateDatasetsXml.sh  EDDTableFromNcCFFiles $indir $ff $indir$ff 180 "" "" "" "" "" "" "" "" "" "" ""

	# get the filename fron the XML output
        filename=$(sed -n 's/<fileNameRegex>\([^<]*\).nc.*/\1/p' ${xmldir}GenerateDatasetsXml.out)
        echo "FILE NAME IN XML OUTPUT: ___  $filename   ___"
	# replace dot with underscore (ERDDAP doesn't allow dots in datasetID)
        filename=$(echo $filename | sed 's/\./_/g' )
	# replace dash with underscore (ERDDAP doesn't allow dashes in datasetID)
        filename=$(echo $filename | sed 's/-/_/g' )

	# replace the datasetID in the XML output with the filename generated above
	sed -i "s/datasetID=\"[^\"]*\"/datasetID=\"${filename}\"/g" ${xmldir}GenerateDatasetsXml.out
	# Mac needs -i flag
	#sed -i"old" "s/datasetID=\"[^\"]*\"/datasetID=\"${filename}\"/g" ${xmldir}GenerateDatasetsXml.out
        #/bin/rm ${xmldir}GenerateDatasetsXml.xmlold

	cat  ${xmldir}GenerateDatasetsXml.out >> $xmldir$outfile
    done

    printf "<!--  End $adir --> \n" >>  $xmldir$outfile
    cd ..

done

