#! /usr/bin/env bash

# default Password Directory
dDIR="$HOME/.local/share/GPGPasswd" # change the path to whatever you want

# colors
cLR="\e[1;91m" # light red 
cLG="\e[1;92m" # light green
cG="\e[1;32m"  # green
cC="\e[1;36m"  # cyan
rC="\e[0m"     # reset color to default 

# text style
tB="\e[1m" # bold text

# Welcome message
welcome (){
  clear
  printf "${cLR}+--------------------------------+\n"
  printf "|${rC} Welcome to GPG PasswordManager${cLR} |\n"
  printf "+--------------------------------+${cR}\n"
}

# Welcome message displayer for encrypt and decrpt options
wcrypt(){
  clear
  printf "${cLG}+-----------------------+\n"
  printf "|${rC}\t$1${cLG} \t|\n"
  printf "+-----------------------+${rC}\n"
}

# Welcome message displayer for vault, about and help options
wmisc (){
  clear
  printf "${cG}+--------------------+\n"
  printf "|${rC}\t $1${cG} \t     |\n"
  printf "+--------------------+${rC}\n"
}

#------------[ Options ]------------------

# Options for the action
options () {
  welcome
  # the main menu
  printf "${cLG}[${rC}${tB}01${cLG}]${cLR} Encrypt    ${cLG}[${rC}${tB}02${cLG}]${cLR} Decrypt\n"
  printf "${cLG}[${rC}${tB}03${cLG}]${cLR} Vault      ${cLG}[${rC}${tB}04${cLG}]${cLR} Backup\n"
  printf "${cLG}[${rC}${tB}05${cLG}]${cLR} Help       ${cLG}[${rC}${tB}06${cLG}]${cLR} About\n"
  read -p $'\n\e[1;92m[\e[0m\e[1m*\e[1;92m] Choose an option: \e[0m\en' option 

  # note : Case Statement can be used instead of if else 
  if [[ $option == 1 || $option == 01 ]]   ; then check_encrypt
  elif [[ $option == 2 || $option == 02 ]] ; then check_decrypt
  elif [[ $option == 3 || $option == 03 ]] ; then list_service
  elif [[ $option == 4 || $option == 04 ]] ; then exit
  elif [[ $option == 5 || $option == 05 ]] ; then help_page
  elif [[ $option == 6 || $option == 06 ]] ; then about_page
  else echo -e "[*] Bye, Be Safe.\n"; exit
  fi
}

#--------------[ List Manager ]------------------

manager () {

  printf "${cLG}[${rC}${tB}01${cLG}]${cLR} Decrypt      ${cLG}[${rC}${tB}02${cLG}]${cLR} Remove${rC}\n"
  read -p $'\n\e[1;92m[\e[0m\e[1m*\e[1;92m] Choose an option: \e[0m\en' opt

  if [[ $opt == 1 || $opt == 01 ]] ; then check_decrypt C
  elif [[ $opt == 2 || $opt == 02 ]] 
  then
      get_service
      if [[ -f "$dDIR/$keyword.gpg" ]]
      then
          printf "[*] Are you sure you want to delete${cLG} $keyword${cR}? [y/N]: "
          read rcheck
          # Services can be choosed based on the numbers it stands in the vault to either decrypt of removed 
          # But since they are shorted according to name, a logic is need, but that's for future
          case $rcheck in
              [yY]* )
                  rm "$dDIR/$keyword.gpg"
                  echo "[*] Deleted"
                  echo "[*] Refreshing.."
                  sleep 1.5
                  list_service;;
              [nN]* | * )
                  echo "[*] Aborted.."
                  list_service;;
          esac
      else
      echo "[*] Service not found. Refreshing"
      sleep 1.5
      list_service
      fi
  elif [[ $opt == "" ]] 
  then
  echo "[*] Hold your horse..."
      sleep 1
      options
  else
      echo "[*] Invalid input. Refreshing..."
      sleep 1.5
      list_service
  fi
}

#==============[ Continue Function ]===============

enter_to_continue (){
  printf "\n[*] Press enter to continue... "
  read enter 
  if [[ $enter == "" ]]
  then
    if [[ $1 == "E" ]]
    then
      check_encrypt
    elif [[ $1 == "DV" ]]
    then
      list_service
    fi
  options
  fi
}

#----------[ Password Directory Check ]--------------

# Passwords Directory Check
checkdir (){
  if [[ ! -d $dDIR ]]
  then
    echo -e "\n[!] Can not locate password directory"
    read -r -p "[*] Do you want to create a new one [y/N]: " newDir
    case $newDir in
    [yY*] )
    mkdir -p $dDIR;;
    [nN]* | * )
    echo -e "\n[=] Edit the script and change the ( dDIR ) variable to your liking\n"
    exit
    esac
  fi
}

#----------------[ Servies ]----------------

# Get the name of the service
get_service () {
  checkdir
  printf "\n[*]${cC} Enter the Keyword for the Service:${rC} " 
  read keyword
}

#---------------------[ Listing Saved GPG Keys ]----------------

# listing all encrypted gpg files in Passwords directory aka the vault
list_service () {

  checkdir; clear
  wmisc Vault

  printf "${cLR}+-----------------------+\n|\t\t\t|\n"
  array=($(ls $dDIR | sed -e "s/.gpg//g"))
  let num_of_service=1
  if [[ ${#array[@]} != 0 ]]
  then
    for service in "${array[@]}"
    do
      printf "| ${cG}$num_of_service. ${rC}$service${cLR} \t\t|\n"
      let num_of_service++
    done
  else
   printf "|${rC}${tB} Cricket Noice ! ${cLR}\t|\n"
  fi
  printf "|\t\t\t|\n+-----------------------+\e\n"
  manager
}

#-----------------[ Encryption ]------------------------

# Checks wheather the service or the file related to it exist or not
check_encrypt (){
  wcrypt Encrypt
  get_service
  if [ -f "$dDIR/$keyword.gpg" ]
  then
  printf "[*]\e[0m\e[1;32m A similar Service named $keyword already seems to exist\n\e[0m"
  read -r -p "[*] Do you want to continue ? This may override the existing file [y/N]: " check
  case $check in
      [yY]* )
      encryption similar;;
      [nN]* | * )
      echo "[*] Terminating Process..."
      sleep 1.2
      check_encrypt;;
  esac

  elif [[ $keyword == "" ]]
  then
      echo "[*] Please make a valid entry"
      sleep 1
      check_encrypt
  else
      encryption 
  fi
}

encryption () {

  if [[ $1 != "similar" ]]
  then
    printf "[*] Are you sure you want to create this service named\e[1;32m $keyword\e[0m? [y/N]: "
    read chec2
  else
    chec2="y"
  fi
  case $chec2 in
  [yY]* )
      echo -n "[*] Enter the password for the service $keyword : "
      read -s passwd
      if [[ $passwd == "" || $passwd == " "* ]]
      then
        printf "\n\n[*] \e[1;31mEmpty password not tolarable (╯°□°)╯︵ ┻━┻ \e[0m"
        enter_to_continue E
        check_encrypt
      fi
      echo "" 
      echo -n "[*] Re-enter the password to confirm : "
      read -s passwd2
      if [[ $passwd == $passwd2 ]]
      then
          printf "\n[*]${cLG} password confirmed\e[0m\n"
          printf "[*] Initializaing MasterKey Prompt...."
          sleep 2
          
          # this is really bad, buty i will impliment the better way soon
          mkdir -p $dDIR/tmp  && touch "$dDIR/tmp/$keyword" && echo $passwd2 > "$dDIR/tmp/$keyword"
          gpg --cipher-algo AES-256 -c --no-symkey-cache  $dDIR/tmp/$keyword && mv $dDIR/tmp/$keyword.gpg $dDIR
          rm -rf $dDIR/tmp
          # can be made simple or maybe much complex and secure, but for now it's ok =) 
          
          echo "[*] Key Saved. Initializing Main Menu..."
          sleep 2
          options
      elif  [[ $passwd2 == "" || $passwd2 == " "* ]]
      then
          echo -e "\n\n[*] Couldn't verify it as an apropriate password.."
          echo "[*] Process Terminated. Refreshing...."
          enter_to_continue
          check_encrypt
      else
          printf "\n[*]${cLR} Password did't match${rC}\n"
          enter_to_continue E
      fi ;;
  [nN]* )
      echo "[*] Process Terminated. Refreshing"
      sleep 0.5
      check_encrypt ;;
  * )
      echo "[*] NULL input, Terminating Process"
      sleep 0.5
      check_encrypt
  esac
}

#-------------------[ Decryption ]--------------

check_decrypt () {
  
  if [[ $1 != "C" ]]
  then
    clear
    wcrypt Decrypt
    get_service
  else
    get_service
  fi
  
  if [ -f "$dDIR/$keyword.gpg" ]
  then
      decrytion
  elif [[ $keyword == "" ]]
  then
      options
  else
      printf "[*]${rLR} Unable to find the service $keyword in Vault\n${rC}"
      if [[ $1 != "C" ]]
      then
        echo -n "[*] Do you want to check stored services? [Y/n]: "
      else
        enter_to_continue DV # Decryption Vault
      fi
      read scheck # service check
          case $scheck in
              [yY]* )
                  echo "[*] Moving to Vault.."
                  sleep 1
                  clear
                  list_service;;
              [nN]* )
                  echo "[*] Exiting.."
                  sleep 1
                  options;;
              * )
                  echo "[*] Moving to Vault.."
                  sleep 1
                  clear
                  list_service;;
              esac
  fi
}

decrytion () {

  echo "[*] Starting decrytion..."
  sleep 0.6
  printf "[*]${cG} Make sure no one is arround you, the password will be shown in plain text\n${rC}"
  read -r -p "[*] Are you sure you want to view the password? [y/N] " view
  echo ""
  
  case $view in
      [yY]* )    
          cat $dDIR/$keyword.gpg | gpg --no-symkey-cache > .tmp
          echo -ne "\n[*] Your password for $keyword is: $(cat .tmp && rm .tmp)" 
          enter_to_continue
          options;;
      [nN]* | * )
          options;;
      esac
}

#----------------[ About && Help ]-------------

about_page() {
  clear
  wmisc About
  cat ./src/about.txt
  enter_to_continue
}

help_page() {
  clear
  wmisc Help
  cat ./src/manual.txt
  enter_to_continue
}

# Initializing options as the Starting function
options









