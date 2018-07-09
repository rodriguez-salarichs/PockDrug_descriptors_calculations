#!/bin/bash


H_kyle="ILE:4.5|VAL:4.2|LEU:3.8|PHE:2.8|CYS:2.5|MET:1.9|ALA:1.8|GLY:-0.4|THR:-0.7|SER:-0.8|TRP:-0.9|TYR:-1.3|PRO:-1.6|HIS:-3.2|GLU:-3.5|GLN:-3.5|ASP:-3.5|ASN:-3.5|LYS:-3.9|ARG:-4.5"


usage=$(cat << EOF

    This script calculates the PockDrug descriptors of a pocket. 

#########################################################################################
    IMPORTANT: This script uses RADI to calculate the geometric descriptors 
      (RADIUS_CYLINDER, SMALLEST_SIZE, VOLUME_HULL, RADIUS_HULL, DIAMETER_HULL, SURFACE_HULL) 

     Borrel, A., Regad, L., Xhaard, H., Petitjean, M., & Camproux, A. C. (2015). PockDrug: a model for predicting pocket druggability that overcomes pocket estimation uncertainties. Journal of chemical information and modeling, 55(4), 882-895.
#########################################################################################
   
   script.sh [options] -i file.pdb -f RADI

    options:

      -i PDB file
      -f RADI executable
      -h Print this help

    version:

      version : 0.1
      author : Dr. Javier Rodriguez-Salarichs

EOF
);

while getopts ":i:f:h" opt; do
  case $opt in
    i)
      INPUT=$OPTARG
      ;;
    f)
      RADI=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "$usage"
      exit 1;
      ;;
    h)
       echo "$usage"
       exit 1;
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1;
      ;;
  esac
done

if [ ${#INPUT} -eq 0 ];then
	echo -e "\n\t####Invalid option####"
	echo "$usage"
	exit 1
fi

#echo $INPUT
#echo "$H_kyle"

#awk -v H_kyle="$H_kyle" 'BEGIN{k="NNN N NNN";i=0;split(H_kyle,c,"|");for(l=1;l<=20;l++){split(c[l],d,":");e[l,1]=d[1];e[l,2]=d[2]}}{if($0 ~ "ATOM"){ki=substr($0,17,10);if(k!=ki){k=ki;i++;a[i]=$4}}}END{for(l=1;l<=i;l++){for(x=1;x<=20;x++){if(e[x,1]==a[l]){sum+=e[x,2]}}};print sum/i}' $INPUT

awk -v H_kyle="$H_kyle" 'BEGIN{k="NNN N NNN";i=0;iT=0;p_aromatic;p_Otyr=0;split(H_kyle,c,"|");for(l=1;l<=20;l++){split(c[l],d,":");e[l,1]=d[1];e[l,2]=d[2]}}{if($0 ~ "ATOM"){iT+=1;if($4=="TYR" && ($3 == "OH" || $3 == "HO")){p_Otyr+=1};ki=substr($0,17,10);if(k!=ki){k=ki;i++;a[i]=$4}}}END{for(l=1;l<=i;l++){if(a[l]=="PHE"||a[l]=="TYR"||a[l]=="HIS"||a[l]=="TRP"){p_aromatic+=1};for(x=1;x<=20;x++){if(e[x,1]==a[l]){sum+=e[x,2]}}};print "hydrophobicity_kyle:",sum/i,"\np_aromatic_residues:",p_aromatic/i,"\np_Otyr_atom:",p_Otyr/iT}' $INPUT


echo -e "PDB\n"$INPUT"\nEPSTAB" &>text_$$.in

$RADI < text_$$.in &> text_$$.out

rm text_$$.in

awk '{if($0 ~"3D HULL : SURFACE"){print "SURFACE_HULL:",$6,"\nVOLUME_HULL:",$10};if($0 ~ "DIAMETER ="){print "DIAMETER_HULL:",$3};if($0 ~ "RADIUS   ="){print "RADIUS_HULL:",$3};if($0 ~ "SMALLEST SIZE :"){print "SMALLEST_SIZE:",$4};if($0 ~ "; RADIUS ="){print "RADIUS_CYLINDER:",$7}}' text_$$.out

rm text_$$.out


exit



































