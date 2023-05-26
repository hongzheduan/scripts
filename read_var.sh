#!/bin/bash

DS_NAME=$(cat file_name_in_use.txt)
TARGET_FIELDS=$(cat fieldlist.txt)

cat id.csv | sed 's/,$/,NA/g' > ${DS_NAME}.csv
for TARGET in ${TARGET_FIELDS};do
  N_TARGET=$(awk -v target="$TARGET" 'BEGIN{FS=OFS="\t"}$1==target{printf("%s_%s\n", $5,$4)}' dictionary_final.tsv | wc -l)
  for EACH_TARGET in $(eval echo "{1..$N_TARGET}");do
      COHORT_N=$(awk -v target="$TARGET" 'BEGIN{FS=OFS="\t"}$1==target{printf("%s_%s\n", $5,$4)}' dictionary_final.tsv | head -${EACH_TARGET} | tail -1 | awk '{split($1,a,"_"); print a[1]}')
      COLUMN_N=$(awk -v target="$TARGET" 'BEGIN{FS=OFS="\t"}$1==target{printf("%s_%s\n", $5,$4)}' dictionary_final.tsv | head -${EACH_TARGET} | tail -1 | awk '{split($1,a,"_"); print a[2]}')
      echo field $TARGET has $N_TARGET records, working on cohort number ${COHORT_N} and column number ${COLUMN_N}
      if [ "$COHORT_N" -le 9 ]; then
          ANALYRIC_FILE_NAME="pheno_AD-Infect_all_00${COHORT_N}_v20230419_FN_raw_participant"
      else
          ANALYRIC_FILE_NAME="pheno_AD-Infect_all_0${COHORT_N}_v20230419_FN_raw_participant"
      fi;
      awk -v var="$COLUMN_N" 'BEGIN{FS=OFS=","}{print $1,$var}' ${ANALYRIC_FILE_NAME}.csv |
      sed 's/,$/,NA/g' |
      awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$2;next}{$(NF+1)=a[$1];print}' FS="," - FS="," ${DS_NAME}.csv > ${DS_NAME}2.csv
      cat ${DS_NAME}2.csv > ${DS_NAME}.csv
   done;
done;
rm ${DS_NAME}2.csv
