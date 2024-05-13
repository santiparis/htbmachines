#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Variables globales
function ctrl_c(){
  echo -e "\n\n${redColour}[!] Exiting the program...${endColour}\n"
  tput cnorm && exit 1
}

# Ctrl + c
trap ctrl_c INT

main_url="https://htbmachines.github.io/bundle.js"

function updateFiles(){
  if [ ! -f /opt/htbmachines/bundle.js ]; then 
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Downloading necessary files...${endColour}"
    curl -s GET $main_url > /opt/htbmachines/bundle.js
    js-beautify /opt/htbmachines/bundle.js | sponge /opt/htbmachines/bundle.js 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Successfully downloaded necessary files${endColour}"
    tput cnorm
  else
    curl -s GET $main_url > /opt/htbmachines/bundle_temp.js
    js-beautify /opt/htbmachines/bundle_temp.js | sponge /opt/htbmachines/bundle_temp.js
    md5_temp=$(md5sum /opt/htbmachines/bundle_temp.js | awk '{print $1}')
    md5=$(md5sum /opt/htbmachines/bundle.js | awk '{print $1}')
    if [ $md5 != $md5_temp ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Updating necessary files ...${endColour}"
      tput civis
      rm /opt/htbmachines/bundle.js
      mv /opt/htbmachines/bundle_temp.js bundle.js
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Necessary files up to date${endColour}"
      tput cnorm
    else
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Necessary files up to date${endColour}"
      rm /opt/htbmachines/bundle_temp.js
    fi
  fi
}

function searchMachine(){
  machineName="$1"
  data="$(cat /opt/htbmachines/bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '",' | sed "s/^ *//" | sed "s/so/os/" | sed "s/dificultad/difficulty/")"
  if [ "$data" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${blueColour} ${machineName}${endColour}${grayColour} machine data:${endColour}\n"
    echo "${data}"
  else
    echo -e "\n${yellowColour}[!] Machine not found${endColour}\n"
  fi
}

function searchIP(){
  ipAdress="$1"
  machineName="$(cat /opt/htbmachines/bundle.js | grep "ip: \"$ipAdress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '",')"

  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} The corresponding machine is${endColour}${purpleColour} $machineName${endColour}\n"
  else
    echo -e "\n${yellowColour}[!] Machine not found${endColour}\n"
  fi
}

function searchLink(){
  machineName="$1"
  machineLink="$(cat /opt/htbmachines/bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '",' | sed "s/^ *//" | grep "youtube" | awk "NF{print $NF}")"

  if [ "$machineLink" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Link to${endColour}${purpleColour} ${machineName}${endColour}${grayColour} machine resolution:${endColour}${redColour} ${machineLink}${endColour}\n"
  else
    echo -e "\n${yellowColour}[!] Machine not found${endColour}\n"
  fi
}

function listDifficulty(){
  difficulty="$1"
  list="$(cat /opt/htbmachines/bundle.js | sed "s/í/i/g" | sed "s/á/a/g" | grep "dificultad: \"${difficulty}\"" -B 5 -i | grep "name: " | awk 'NF{print $NF}' | tr -d '",' | column)"

  if [ "$list" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listing${endColour}${purpleColour} ${difficulty}${endColour}${grayColour} difficulty machines:${endColour}\n"
    echo -e "${redColour}${list}${endColour}"
  else
    echo -e "\n${yellowColour}[!] Difficulty not found${endColour}\n"
  fi
}

function listOS(){
  os="$1"
  list="$(cat /opt/htbmachines/bundle.js | grep "so: \"${os}\"" -B 4 -i | grep "name: " | awk 'NF{print $NF}' | tr -d '",' | column)"

  if [ "$list" ]; then
    echo -e "\n${yellowCOlour}[+]${endColour}${grayColour} Listing machines with${endColour}${purpleColour} ${os}${endColour}\n"
    echo -e "${redColour}${list}${endColour}\n"
  else
    echo -e "\n${yellowColour}[!] OS not found${endColour}\n"
  fi
}

function searchDifficultyOS(){
  difficulty="$1"
  os="$2"
  list="$(cat /opt/htbmachines/bundle.js | sed "s/í/i/g" | sed "s/á/a/g" | grep "dificultad: \"${difficulty}\"" -B 5 -i | grep "so: \"${os}\"" -B 4 -i | grep "name: " | awk 'NF{print $NF}' | tr -d '",' | column)"

  if [ "$list" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listing machines with${endColour}${purpleColour} ${difficulty}${endColour}${grayColour} difficulty and${endClour}${purpleColour} ${os}${endColour}${grayColour} OS:${endColour}\n"
    echo -e "${redColour}${list}${endColour}\n"
  else
    echo -e "\n${yellowColour}[!] Machine not found${endColour}\n"
  fi

}

function listSkill(){
  skill="$1"
  list="$(cat /opt/htbmachines/bundle.js | grep "skills: " -B 6 | grep "${skill}" -B6 -i | grep "name: " | awk 'NF{print $NF}' | tr -d '",' | column)"

  if [ "$list" ]; then
    echo -e "${yellowColour}[+]${endColour}${grayColour} Listing machines that require${endColour}${purpleColour} ${skill}${endColour}${grayColour} skill:${endColour}\n"
    echo -e "${redColour}${list}${endColour}"
  else
    echo -e "\n${yellowColour}[!] Skill not found${endColour}\n"
  fi
}

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Arguments:${endColour}\n"
  echo -e "\t${purpleColour}-u\t${endColour}${grayColour} Download or update necessary files${endColour}"
  echo -e "\t${purpleColour}-m\t${endColour}${grayColour} Search with machine name (-m [MACHINE])${endColour}"
  echo -e "\t${purpleColour}-i\t${endColour}${grayColour} Search with machine IP name (-m [IP])${endColour}"
  echo -e "\t${purpleColour}-y\t${endColour}${grayColour} Get link to machine resolution (-y [MACHINE])${endColour}"
  echo -e "\t${purpleColour}-d\t${endColour}${grayColour} List machines by difficulty (-d [DIFFICULTY])${endColour}"
  echo -e "\t${purpleColour}-o\t${endColour}${grayColour} List machines by OS (-o [OS])${endColour}"
  echo -e "\t${purpleColour}-s\t${endColour}${grayColour} List machines by skill (-o [SKILL])${endColour}"
  echo -e "\t${purpleColour}-h\t${endColour}${grayColour} Show help panel\n${endColour}"
  echo -e "${redColour}[!]${endColour}${grayColour} If you want to search by difficulty and OS input -d [DIFFICULTY] and -o [OS] (in that order)${endColour}\n"
}

# Flags
declare -i flag_difficulty=0
declare -i flag_os=0

# Indicadores
declare -i parameter_counter=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAdress=$OPTARG; let parameter_counter+=3;;
    y) machineName=$OPTARG; let parameter_counter+=4;;
    d) difficulty=$OPTARG; let flag_difficulty=1; let parameter_counter+=5;;
    o) os=$OPTARG; let flag_os=1; let parameter_counter+=6;;
    s) skill=$OPTARG; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName;
elif [ $parameter_counter -eq 2 ]; then
  updateFiles;
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAdress;
elif [ $parameter_counter -eq 4 ]; then
  searchLink $machineName;
elif [ $parameter_counter -eq 5 ]; then
  listDifficulty $difficulty;
elif [ $parameter_counter -eq 6 ]; then
  listOS $os;
elif [ $parameter_counter -eq 7 ]; then
  listSkill "$skill";
elif [ $flag_difficulty -eq 1 ] && [ $flag_os -eq 1 ]; then
  searchDifficultyOS $difficulty $os;
else
  helpPanel;
fi

