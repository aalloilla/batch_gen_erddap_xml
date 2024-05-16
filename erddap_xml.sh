#!/bin/bash
#
#---script to generate xml files for all the nc files in a directory.
#---indir = input directory
#---outdir = output directory
#---outfile= output file containing all the xml files

indir=/Users/mstoessel/GOMRI/MBON/Walton/Walton-Smith/WS22141_Profile/
outdir=/Library/erddap_data/erddap/logs/
outfile=GenerateDatasetsXml_WS22141.out

printf "<!--  Start WS22141 --> \n \n \n" > $outdir$outfile

cd $indir

for ff in `ls *.nc`

do
	echo $ff

        cd /Library/Tomcat/apache-tomcat-9.0.54/webapps/erddap/WEB-INF/
        GenerateDatasetsXml.sh  EDDTableFromNcCFFiles $indir $ff $indir$ff 80 "" "" "" "" "" "" "" "" "" "" ""

        filename=$(sed -n 's/<fileNameRegex>\([^<]*\).nc.*/\1/p' ${outdir}GenerateDatasetsXml.out)

        filename=$(echo $filename | sed 's/\./_/g' )

        sed -i"old" "s/datasetID=\"[^\"]*\"/datasetID=\"${filename}\"/g" ${outdir}GenerateDatasetsXml.out

        /bin/rm ${outdir}GenerateDatasetsXml.xmlold

	cat  ${outdir}GenerateDatasetsXml.out >> $outdir$outfile
done

printf "<!--  End WS22141 --> \n" >>  $outdir$outfile
