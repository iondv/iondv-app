#!/bin/bash
scriptPath=${0%/*}
source $scriptPath/color.cfg

if [ $# -lt 3 ] ; then
  echo 'Usage: change-namespace.sh path orginal_namespace new_namespace'
  echo 'IONDV. Framework application change namespace with typically app folders.'
  echo
  echo 'Example:'
  echo '  ./change-namespace.sh ./applications/crm-new crm-prev crm-new'
  exit
fi
IFS_def=$IFS
curDate=`date +"%Y%m%d-%H-%M"`

while [ -n "$1" ]
do
  case "$1" in
    -q) quietMode=1; paramInfo="$paramInfo\nFound the quiet data option";;
    *)  if [[ ${1:0:1} == "-" ]] ; then 
        echo "$1 is not an option" 
        shift
        else 
          if ! [ $appPath ] ; then
            appPath=$1
          elif ! [ $nsPrev ] ; then
            nsPrev=$1
          elif ! [ $nsNew ] ; then
            nsNew=$1
          else
            echo "Exteneded parameters, ignored"
          fi
        fi;;
  esac
shift
done
if ! [ $quietMode ] ; then echo -e $paramInfo; fi


if ! [ -d $appPath ]; then
  echo "${i_crit}Path $appPath is wrong${i_end}"
  exit
fi

# Function for check the previous namespace and rename temporary filename to original file
# $1 - path to prepared filename 
function checkPrevNsAndRenameFile {
  local prepareFile=$1
  mv -f "$prepareFile-$curDate" $prepareFile
  local checkRes=`grep -n "$nsPrev" "$prepareFile"`
  if [ ${#checkRes} -ne 0 ] ; then
    echo -en "  ${i_warn}didn't all $nsPrev replace to $nsNew in $prepareFile. Need manual check${i_end}"
    echo -en "  ${i_warn}" && grep -n "$nsPrev" "$prepareFile" && echo -en "${i_std}"
  fi
}

fileCount=0
filePrepareCount=0

# Function for change namespace in different instraction for different folder
# $1 - prepared app folder
# $2 - prepared file
function changeNamespace {
  local prepareFile=$2
  # Skip files
  # Specific folder prepare
  case "$1" in 
    'data')
      if [ ${prepareFile##*.} = 'zip' ] ; then
        if ! [ $quietMode ] ; then  echo -en "  ${i_debug}skip zip: $prepareFile${i_end}"; fi
        return
      fi
      ;;
    * )
      ;;
  esac

  # Files prepare
  local checkRes=`grep -n "$nsPrev" "$prepareFile"`
  if [ ${#checkRes} -eq 0 ] ; then return; fi
  case "$1" in
    'acl')
      if [[ ${prepareFile##*.} = 'yml' || ${prepareFile##*.} = 'json' ]] ; then
        cat $prepareFile |
          sed -r "s|\"namespace\"\s*:\s*\"$nsPrev\"|\"namespace\": \"$nsNew\"|"  |
          sed -r "s|/$nsPrev@|/$nsNew@|" |
          sed -r "s|@$nsPrev:|@$nsNew:|" |
          sed -r "s|:$nsPrev@|:$nsNew@|"> "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;
    'bi')
      if echo $prepareFile | grep -Eq "/bi/navigation/"; then
        if [ ${prepareFile##*.} = 'json' ] ; then
          cat $prepareFile |
            sed -r "s|\"namespace\"\s*:\s*\"$nsPrev\"|\"namespace\": \"$nsNew\"|"  |
            sed -r "s|\"mine\"\s*:\s*\"$nsPrev@|\"mine\": \"$nsNew@|" > "$prepareFile-$curDate"
          local prepared=1
        fi
      fi
      ;;
    'data')
      if [ ${prepareFile##*.} = 'json' ] ; then
        cat $prepareFile |
          sed -r "s|@$nsPrev\"|@$nsNew\"|" > "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;
    'dashboard')
      if [ ${prepareFile##*.} = 'ejs' ] ; then
        cat $prepareFile |
          sed -r "s|registry/$nsPrev@|registry/$nsNew@|" |
          sed -r "/registry\/api/{s/@$nsPrev/@$nsNew/;}" |
          sed -r "/dashboard\.getWidget/{s/'$nsPrev/'$nsNew/;}" |                 #  dashboard.getWidget('test-pm-task')
          sed -r "/node:/{s/$nsPrev@/$nsNew@/;}" |
          sed -r "s|dashboard/$nsPrev|dashboard/$nsNew|" > "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;

    'geo')
      if echo $prepareFile | grep -Eq "/geo/layers/"; then
        if [ ${prepareFile##*.} = 'json' ] ; then
          cat $prepareFile |
            sed -r "s|geomap/render/$nsPrev|geomap/render/$nsNew|" |
            sed -r "s|@$nsPrev\"|@$nsNew\"|" |
            sed -r "s|/registry/$nsPrev@|/registry/$nsNew@|" |
            sed -r "s|@$nsPrev/|@$nsNew/|" > "$prepareFile-$curDate"
          local prepared=1
        fi
      elif echo $prepareFile | grep -Eq "/geo/navigation/" ; then
        if [ ${prepareFile##*.} = 'json' ] ; then 
          cat $prepareFile |
            sed -r "s|geomap/render/$nsPrev|geomap/render/$nsNew|" | \
            sed -r "s|@$nsPrev\"|@$nsNew\"|" > "$prepareFile-$curDate"
          local prepared=1
        fi
      fi
      ;;
    'meta')
      if [ ${prepareFile##*.} = 'json' ] ; then 
        cat $prepareFile |
          sed -r "s|\"namespace\"\s*:\s*\"$nsPrev\"|\"namespace\": \"$nsNew\"|"  |
          sed -r "s|@$nsPrev\"|@$nsNew\"|" |
          sed -r "s|@$nsPrev,|@$nsNew,|" > "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;
    'views')
      if [ ${prepareFile##*.} = 'json' ] ; then
        cat $prepareFile |
          sed -r "s|\"namespace\"\s*:\s*\"$nsPrev\"|\"namespace\": \"$nsNew\"|"  |
          sed -r "s|/report/public/$nsPrev@|/report/public/$nsNew@|" |
          sed -r "s|@$nsPrev\"|@$nsNew\"|" > "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;
    'navigation')
      if [ ${prepareFile##*.} = 'json' ] ; then 
        cat $prepareFile |
          sed -r "s|\"namespace\"\s*:\s*\"$nsPrev\"|\"namespace\": \"$nsNew\"|"  |
          sed -r "s|@$nsPrev\"|@$nsNew\"|" > "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;
    'templates')
      if [ ${prepareFile##*.} = 'ejs' ] ; then
        cat $prepareFile |
          sed -r "s|geomap/render/$nsPrev|geomap/render/$nsNew|" |
          sed -r "s|/report/public/$nsPrev@|/report/public/$nsNew@|" |
          sed -r "s|$nsPrev([\/\\])templates|$nsNew\1templates|" |                      # test-pm\templates   # TODO (!) ПУСТЫЕ ФАЙЛЫ
          sed -r "s|report/$nsPrev@|report/$nsNew@|" |
          sed -r "s|registry/$nsPrev@|/registry/$nsNew@|" |
          sed -r "s|@$nsPrev/|@$nsNew/|" |
          sed -r "s|@$nsPrev'|@$nsNew'|" |
          sed -r "s|@$nsPrev\`|@$nsNew\`|" |
          sed -r "s|'$nsPrev@|'$nsNew@|" > "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;
    'themes')
      if [ ${prepareFile##*.} = 'js' ] ; then
        cat $prepareFile |
          sed -r "s|report/$nsPrev@|report/$nsNew@|" |
          sed -r "s|@$nsPrev'|@$nsNew'|" |
          sed -r "s|@$nsPrev/'|@$nsNew/'|"> "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;
    'wfviews')
      if [ ${prepareFile##*.} = 'json' ] ; then
        cat $prepareFile |
          sed -r "s|@$nsPrev\"|@$nsNew\"|" |
          sed -r "s|/report/public/$nsPrev@|/report/public/$nsNew@|" > "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;
    'workflows')
      if [ ${prepareFile##*.} = 'json' ] ; then
        cat $prepareFile |
          sed -r "s|@$nsPrev\"|@$nsNew\"|" |
          sed -r "s|/$nsPrev@|/$nsNew@|" > "$prepareFile-$curDate"
        local prepared=1
      fi
      ;;
    * )
      if [ ${prepareFile##*.} = 'json' ] ; then
        echo -en "${i_warn}Folder \"$1\" didn't have instruction to prepare. Use default check and replace for $prepareFile${i_end}";
        cat $prepareFile |
          sed -r "s|\"applications/$nsPrev/|\"applications/$nsNew/|" |
          sed -r "s|\"namespace\"\s*:\s*\"$nsPrev\"|\"namespace\": \"$nsNew\"|" > "$prepareFile-$curDate"
      local prepared=1
      elif [ ${prepareFile##*.} = 'js' ] ; then
        echo -en "${i_warn}Folder \"$1\" didn't have instruction to prepare. Use default check and replace for $prepareFile${i_end}";
        cat $prepareFile |
          sed -r "s|(['\"])([a-zA-Z0-9_]+)@$nsPrev(['\"])|\1\2@$nsNew\3|" |  # 'eventControl@test-pm'
          sed -r "s|(['\"])([a-zA-Z0-9_]+)@$nsPrev([\.a-zA-Z0-9_]+)(['\"])|\1\2@$nsNew\3\4|" |   # 'project@test-pm.inaccepted' 'indicatorBasic@test-pm.'
          sed -r "s|@$nsPrev'|@$nsNew'|" > "$prepareFile-$curDate"
        local prepared=1
      else
        echo -en "${i_warn}Folder \"$1\" didn't have instruction to prepare and didn't recognize extension for use default check and replace for $prepareFile. Skip${i_end}";
        echo -en "  ${i_warn}" && grep -n "$nsPrev" "$prepareFile" && echo -en "${i_std}";
        return
      fi
      ;;
  esac
  if [ $prepared ] ; then
    if ! [ $quietMode ] ; then echo -en "${i_debug}  prepared: $prepareFile${i_end}"; fi
    filePrepareCount=$(( $filePrepareCount + 1 ))
    checkPrevNsAndRenameFile $prepareFile
  else
   echo -en "${i_warn}$prepareFile didn't have instruction to prepare. Skip${i_end}";
   echo -en "  ${i_warn}" && grep -n "$nsPrev" "$prepareFile" && echo -en "${i_std}";
   return
  fi
}

function renameNamespaceFolder {
  if [[ "$1" = "export" && "$2"="$nsPrev" ]]; then
    newFolderName="${2%/*}/$nsNew"
    if ! [ $quietMode ] ; then echo -en "${i_info}  ${2} export subfolder have $nsPrev. Rename to ${newFolderName}${i_end}"; fi
    mv -T "$2" "${newFolderName}"
  elif echo "${2##*/}" | grep -q "@$nsPrev"; then
    newFolderName=`echo "${2##*/}" | sed "s|@$nsPrev|@$nsNew|"`
    newFolderName="${2%/*}/$newFolderName"
    if ! [ $quietMode ] ; then echo -en "${i_info}  ${2} folder have $nsPrev. Rename to ${newFolderName}${i_end}"; fi
    mv -T "$2" "${newFolderName}"
  else
    newFolderName=$2
    echo -en "${i_warn}  ${2} folder have $nsPrev. But didn't found instruction. Skip${i_end}"
  fi
}

function renameNamespaceFile {
  case "$1" in
    'data')
        local tempName=${2%@*}
        newFileName="${tempName%@*}@$nsNew@${2##*@}"
        if ! [ $quietMode ] ; then echo -en "${i_info}  ${2} => ${newFileName##*/} rename because have $nsPrev in filename${i_end}";  fi
        mv "$2" "${newFileName}"
        ;;
    'views')
      if echo $2 | grep -Eq "/views/workflows/"; then
        if echo "${2##*/}" | grep -q "@$nsPrev"; then
          newFileName="${2%@*}@$nsNew.${2##*.}"
          if ! [ $quietMode ] ; then echo -en "${i_info}  ${2} => ${newFileName##*/} rename because have $nsPrev in filename${i_end}"; fi
          mv "$2" "$newFileName";
        else
          newFileName=$2
          echo -en "${i_warn}  ${2} file in views/workflow have $nsPrev. But didn't found instruction. Skip${i_end}"
        fi
      fi
                ;;
    'wfviews')
        if echo "${2##*/}" | grep -q "@$nsPrev"; then
          newFileName="${2%@*}@$nsNew.${2##*.}"
          if ! [ $quietMode ] ; then echo -en "${i_info}  ${2} => ${newFileName##*/} rename because have $nsPrev in filename${i_end}"; fi
          mv "$2" "$newFileName";
        else
          newFileName=$2
          echo -en "${i_warn}  ${2} file in wfviews have $nsPrev. But didn't found instruction. Skip${i_end}"
        fi
        ;;

    * )
        newFileName=$2
        echo -en "${i_warn}  ${2} file have $nsPrev. But didn't found instruction. Skip${i_end}"
        ;;
  esac
}


# Recursive function for cnange namespasece in all files in folder
# $1 - prepared app folder
# $2 - folder for search files to prepare 
function changeNsInAllFilesInFolder {
  local filesPath=$2
  for file in "$filesPath"/* ; do
    if [ -f "$file" ] ; then
      fileCount=$(( $fileCount + 1 ))
      if echo "${file##*/}" | grep -q "$nsPrev"; then
        renameNamespaceFile $1 "$file"
        changeNamespace $1 $newFileName
      else
        changeNamespace $1 $file
      fi


    elif [ -d "$file" ] ; then
      if echo "${file##*/}" | grep -q "$nsPrev"; then
        renameNamespaceFolder $1 "$file"
        changeNsInAllFilesInFolder $1 "$newFolderName"
      else
        changeNsInAllFilesInFolder $1 "$file"
      fi
    fi
  done
}


for folder in "$appPath"/* ; do
  fileCount=0
  filePrepareCount=0
  if [ -d "$folder" ] ; then
    prepareFolder="${folder##*/}"
    changeNsInAllFilesInFolder "$prepareFolder" "$folder"
    if ! [ $quietMode ] ; then echo "${prepareFolder} prepared $filePrepareCount($fileCount)"; fi
  fi
done


if [ -f "$appPath/package.json" ] ; then
  if ! [ $quietMode ] ; then echo "Process package.json"; fi
  cat $appPath/package.json |
    sed -r "s|\"name\"\s*:\s*\"$nsPrev\"|\"name\": \"$nsNew\"|" > $appPath/package_temp_$curDate.json
  mv -f $appPath/package_temp_$curDate.json $appPath/package.json
fi

if [ -f "$appPath/deploy.json" ] ; then
  if ! [ $quietMode ] ; then echo "Process deploy.json"; fi
  cat $appPath/deploy.json | \
    sed -r "s|\"applications/$nsPrev/|\"applications/$nsNew/|" |
    sed -r "s|\"namespace\"\s*:\s*\"$nsPrev\"|\"namespace\": \"$nsNew\"|" |
    sed -r "/\"url\"\s*:\s*\"/{s/registry\/$nsPrev@/registry\/$nsNew@/;}" |
    sed -r "/\"className\"\s*:/{s/\"(\w+)@$nsPrev\"/\"\1@$nsNew\"/;}" |            # "className": "project@test-pm"
    sed -r "/\"node\"\s*:/{s/\"$nsPrev@(\w+)\"/\"$nsNew@\1\"/;}" |                 # "node": "test-pm@eventBasic"
    sed -r "s|\"([\.a-zA-Z0-9_]+)@$nsPrev\"\s*:\s*\{|\"\1@$nsNew\": \{|" |        # "person@test-pm": {
    sed -r "s|/registry/$nsPrev@([\.a-zA-Z0-9_]+)\"|/registry/$nsNew@\1\"|" |     # "^/registry/test-pm@indicatorValue.all",
    sed -r "s|(\"\w+)@$nsPrev([\.:a-zA-Z0-9_]+)\"\s*:\s*\{|\1@$nsNew\2\": \{|" |  # "project@test-pm.edit": {   # "eventBasic@test-pm:mapAIP": {
    sed -r "s|\"$nsPrev\"\s*:\s*\{|\"$nsNew\": \{|" |                              # "test-pm": {
    sed -r "s|\"$nsPrev\"\s*:\s*\"|\"$nsNew\": \"|" |                              # "test-pm": "Project management"
    sed -r "s|\"([a-zA-Z0-9_]+)@$nsPrev([\.a-zA-Z0-9_]+)\"|\"\1@$nsNew\2\"|" |   # "resultEvent@test-pm.work"
    sed -r "s|\"registry/$nsPrev@([\.a-zA-Z0-9_]+)/|\"registry/$nsNew@\1/|" |       # "registry/test-pm@myprojectevent.all/new/
    sed -r "s|/([a-zA-Z0-9_]+)/([a-zA-Z0-9_]+)@$nsPrev\"|/\1/\2@$nsNew\"|"  |    # /basicObjs/event@test-pm"
        sed -r "s|\"([a-zA-Z0-9_]+)@$nsPrev\"|\"\1@$nsNew\"|g" |                  # "indicatorValueBasic@test-pm"
    sed -r "s|\"$nsPrev@([\.a-zA-Z0-9_]+)\"|\"$nsNew@\1\"|g" |                    # "test-pm@projectmanagement"
    sed -r "s|\"theme\"\s*:\s*\"$nsPrev/|\"theme\": \"$nsNew/|" > $appPath/deploy_temp_$curDate.json

  mv -f $appPath/deploy_temp_$curDate.json $appPath/deploy.json
  checkRes=`grep -n "$nsPrev" $appPath/deploy.json`
  if ! [ ${#checkRes} -eq 0 ] ; then
    echo -en "${i_warn}Didn't all $nsPrev replace to $nsNew in deploy.json. Need manual check${i_end}"
    grep -n "$nsPrev" $appPath/deploy.json
  fi
fi
