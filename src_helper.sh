#! /bin/bash
echo "Start!"

# Usage: 
# put this file and patch in the same folder as hp, ricohpr and so on.
# put all_files in ../src/all_files
# in console: src_helper.sh backup|patch [patch name]|diff|file|recover
# 
# Limits:
# this script depends on ../src/all_files,
# which list file to be operated.
#  
# 1. all_files must be unix file format
# 2. source file is 2 layer file.

qacDir="~/QAC"
copyFileDir=../CopyFile
targetDir=../src
targetFile=all_files
iripsFile=irips_inc_path.p_a

help(){

  echo "Usage: src_helper.sh backup | patch [patch name]| diff | file | recover | copyfile [compile dir name]"
}


if [ "$1" == "get" ]; then

  if [ ! -d "${targetDir}" ]; then
    mkdir ${targetDir} 2>&1
  fi

  echo "Find diff file!"
  find -name *.diff > ${targetDir}/diff.list

  echo "File process!"
  cat ${targetDir}/diff.list | while read myline
  do
    folder=`echo $myline | cut -d "/" -f 2`
    file=`echo $myline | cut -d "/" -f 3`
    filename=`echo $file | cut -d "." -f 1`
    suffix=`echo $file | cut -d "." -f 2`
  #echo $folder
  #echo $file
  #echo $filename
  #echo ${filename}.c

    if [ ! -d "${targetDir}/$folder" ]; then
      echo mkdir ${targetDir}/$folder
      mkdir ${targetDir}/$folder 2>&1
    fi

    echo "Copy file"

    echo cp ${folder}/${filename}.${suffix} ${targetDir}/${folder}/${filename}.${suffix}
    cp ${folder}/${filename}.${suffix} ${targetDir}/${folder}/${filename}.${suffix}
    echo cp ${folder}/${filename}.${suffix}.diff ${targetDir}/${folder}/${filename}.${suffix}.diff
    cp ${folder}/${filename}.${suffix}.diff ${targetDir}/${folder}/${filename}.${suffix}.diff
    echo cp ${folder}/${filename}.${suffix}.orig ${targetDir}/${folder}/${filename}.${suffix}.orig
    cp ${folder}/${filename}.${suffix}.orig ${targetDir}/${folder}/${filename}.${suffix}.orig
  done
elif [ "$1" == "help" ]; then
  help

# backup file, copy files in ${targetFile}
elif [ "$1" == "backup" ]; then
  echo "backup file, copy files in ${targetFile}"
  #awk '{printf("%s ",$0)}' ${targetDir}/${targetFile}

  cat ${targetFile} | while read myline
  do
    echo cp ${myline} ${myline}.orig
    cp ${myline} ${myline}.orig
  done

#patch
elif [ "$1" == "patch" ]; then
  #echo $#
  if [ "$#" -lt 2 ] ; then
    help
    exit 1
  fi

  echo patch -p1 "<" $2
  patch -p1 < $2
  
# create diff file, using original and modified file
elif [ "$1" == "diff" ]; then
  echo "create diff file, using original and modified file"

  cat ${targetFile} | while read myline
  do
    echo diff -c ${myline}.orig ${myline} ">" ${myline}.diff
    diff -c ${myline}.orig ${myline} > ${myline}.diff
  done

# create dir which is needed when review
elif [ "$1" == "file" ]; then
  echo "create dir which is needed when review"

  if [ ! -d "${targetDir}" ]; then
    mkdir ${targetDir} 2>&1
  fi
  
  cat ${targetFile} | while read myline
  do
    folder=`echo $myline | cut -d "/" -f 2`
    filename=`echo $myline | cut -d "/" -f 3`

    if [ ! -d "${targetDir}/$folder" ]; then
      echo mkdir ${targetDir}/$folder
      mkdir ${targetDir}/$folder 2>&1
    fi

    echo cp ${myline} ${targetDir}/${folder}/${filename}
    cp ${myline} ${targetDir}/${folder}/${filename}
    echo cp ${myline}.diff ${targetDir}/${folder}/${filename}.diff
    cp ${myline}.diff ${targetDir}/${folder}/${filename}.diff
    echo cp ${myline}.orig ${targetDir}/${folder}/${filename}.orig
    cp ${myline}.orig ${targetDir}/${folder}/${filename}.orig
  done

  #zip -r hp.zip hp
  cd ../
  echo zip -r src.zip src
  zip -r src.zip src 

# recover
elif [ "$1" == "recover" ]; then

  cat ${targetFile} | while read myline
  do
    echo mv ${myline} ${myline}.bak
    mv ${myline} ${myline}.bak
    echo mv ${myline}.orig ${myline}
    mv ${myline}.orig ${myline}
  done

# generate CopyFile
elif [ "$1" == "copyfile" ]; then
  #echo $#
  if [ "$#" -lt 2 ] ; then
    echo "less parameter error!"
    help
    exit 1
  fi

  if [ ! -d "${copyFileDir}" ]; then
    echo mkdir ${copyFileDir} 
    mkdir ${copyFileDir} 2>&1
  fi

  echo cp ${targetFile} ${copyFileDir}/${targetFile}
  cp ${targetFile} ${copyFileDir}/${targetFile}

  catStr="-i \"./""$2""\""
  #echo $catStr

  echo cat ${iripsFile} | sed '2c '"$catStr" > ${copyFileDir}/${iripsFile}
  sed '2c '"$catStr" ${iripsFile} > ${copyFileDir}/${iripsFile}

  if [ ! -d "${copyFileDir}/differ" ]; then
    echo mkdir ${copyFileDir}/differ
    mkdir ${copyFileDir}/differ 2>&1
  fi

  cat ${targetFile} | while read myline
  do
    filename=`echo $myline | cut -d "/" -f 3`
    echo cp ${myline}.diff ${copyFileDir}/"differ"/${filename}.diff
    cp ${myline}.diff ${copyFileDir}/"differ"/${filename}.diff
  done

  if [ ! -d "${copyFileDir}/code" ]; then
    echo mkdir ${copyFileDir}/code
    mkdir ${copyFileDir}/code 2>&1
  fi

  echo cp -rf ./* "${copyFileDir}/code"
  cp -rf ./* "${copyFileDir}/code"

  echo chmod -R 777 ${copyFileDir}/*
  chmod -R 777 ${copyFileDir}/*
  
  cd ~
  qacDir=`pwd`
  cd -
  qacDir=$qacDir/QAC
  echo $qacDir

  cd ..

  echo tar -zcf ${qacDir}/CopyFile.tar.gz CopyFile
  tar -zcf ${qacDir}/CopyFile.tar.gz CopyFile

  echo chmod 777 ${qacDir}/CopyFile.tar.gz
  chmod 777 ${qacDir}/CopyFile.tar.gz

else
  help

fi

echo "End!"
