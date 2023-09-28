#! /usr/bin/env bash

# Default Password Directory
dDIR="$HOME/.local/share/GPGPasswd"

# Default Config file
if [[ ! -f $HOME/.config/BPass/bpass ]]
then
  touch $HOME/.config/BPass/bpass
  echo 'cDIR="$HOME/.local/share/GPGPasswd"' > $HOME/.config/BPass/bpass
  chmod 400 $HOME/.config/BPass/bpass
  echo "[+] Config file created"

# Note : This is not secure which can cause arbitrary code execution, unless proper permission is set.
source $HOME/.config/BPass/bpass

# Welcome message
welcome (){
    printf "\e[1;91m+----------------------------------+\e[0m\n"
    printf "\e[1;91m|\e[0m Welcome to GPG PasswordManager\e[1;91m   |\e[0m\n"
    printf "\e[1;91m+----------------------------------+\e[0m\n"
}

# Welcome message displayer for encrypt and decrpt options
wcrypt(){
    printf "\e[1;92m+-----------------------+\n"
    printf "\e[1;92m|\e[0m\t$1\e[1;92m \t|\n"
    printf "\e[1;92m+-----------------------+\e[0m\n"
}

# Welcome message displayer for  vault, about and help options
wmisc (){
    printf "\e[1;32m+--------------------+\e[0m\n"
    printf "\e[1;32m|\e[0m\t $1\e[1;32m \t     |\n"
    printf "\e[1;32m+--------------------+\e[0m \n"
}

#===========[ Options ]=========

# Options for the action
options () {
    clear
    welcome
    # Need to make global variable for the color values
    printf "\e[1;92m[\e[0m\e[1m01\e[1;92m]\e[1;91m Encrypt\t  \e[1;92m[\e[0m\e[1m02\e[1;92m]\e[1;91m Decrypt\e[0m\n"
    printf "\e[1;92m[\e[0m\e[1m03\e[1;92m]\e[1;91m About        \e[1;92m[\e[0m\e[1m04\e[1;92m]\e[1;91m Help\e[0m\n"
    printf "\e[1;92m[\e[0m\e[1m05\e[1;92m]\e[1;91m Vault        \e[1;92m[\e[0m\e[1m06\e[1;92m]\e[1;91m Exit\e[0m\n"

    read -p $'\n\e[1;92m[\e[0m\e[1m*\e[1;92m] Choose an option: \e[0m\en' option 

    # Case Statement can be used instead of if else 
    if [[ $option == 1 || $option == 01 ]] 
    then
      check_encrypt
    elif [[ $option == 2 || $option == 02 ]] 
    then
      check_decrypt
    elif [[ $option == 3 || $option == 03 ]] 
    then
      about_page
    elif [[ $option == 4 || $option == 04 ]] 
    then
      help_page
    elif [[ $option == 5 || $option == 05 ]] 
    then
      list_service
    elif [[ $option == 6 || $option == 06 ]] 
    then
      echo "[*] Good Bye"
      exit
    else
      echo "[*] Invalid input. Reloading... "
      sleep 1
      options
    fi
}

#===============[ List Manager ]================

manager () {

    printf "\n\e[1;92m[\e[0m\e[1m01\e[1;92m]\e[1;91m Decrypt      \e[1;92m[\e[0m\e[1m02\e[0m\e[1;92m]\e[1;91m Remove\e[0m\n"
    read -p $'\n\e[1;92m[\e[0m\e[1m*\e[1;92m] Choose an option: \e[0m\en' opt

    if [[ $opt == 1 || $opt == 01 ]] 
    then
        check_decrypt C # C for child
    elif [[ $opt == 2 || $opt == 02 ]] 
    then
        get_service
        if [[ -f "./Passwords/$keyword.gpg" ]]
        then
            printf "[*] Are you sure you want to delete\e[1;92m $keyword\e[0m? [y/N]: "
            read rcheck
            # Services can be choosed based on the numbers it stands in the vault to either decrypt of removed 
            # But since they are shorted according to name, a logic is need, but that's for future
            case $rcheck in
                [yY]* )
                    rm "./Passwords/$keyword.gpg"
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
# what="https://www.youtube.com/watch?v=dQw4w9WgXcQ"

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

#========================[ Password Directory Check ]========================

# Passwords Directory Check
checkdir (){
    echo "[*] Running a check..."
    if [[ $cDIR == $dDIR || $cDIR == " " ]]
    then
      pDIR=$dDIR
    elif [[ ]]
    echo "[*] Making the password directory..."
    sleep 0.5
    mkdir -p ./Passwords
    fi
}

#================[ Servies ]=============

# Get the name of the service
get_service (){
checkdir
echo ""
printf "[*]\e[0m\e[1;36m Enter the Keyword for the Service:\e[0m "
# ==> An array can be implimented rather than taking a single input, but not sure how effiecient will that be 
read keyword
}

#===============[ Listing Saved GPG Keys ]=================

# listing all encrypted gpg files in Passwords directory aka the vault
list_service () {
    checkdir
    clear
    wmisc Vault
    printf "\e[1;91m+-----------------------+\e\n |\t\t\t|\n"
    array=($(ls ./Passwords/ | sed -e "s/.gpg//g"))
    let num_of_service=1
    if [[ ${#array[@]} != 0 ]]
    then
      for service in "${array[@]}"
      do
        printf "| \e[1;32m$num_of_service. \e[0m$service\e[1;91m \t\t|\n"
        let num_of_service++
      done
    else
     printf "|\e[0m\e[1m Cricket Noice ! \e[1;91m\t|\n"
    fi
    printf "|\t\t\t|\n\e[1;91m+-----------------------+\e\n"
   manager
}

#====================[ Encryption ]======================

# Checks wheather the service or the file related to it exist or not
check_encrypt (){

clear
wcrypt Encrypt
get_service

if [ -f "./Passwords/$keyword.gpg" ]
then
    printf "[*]\e[0m\e[1;32m A similar Service named $keyword already seems to exist\n\e[0m"
    read -r -p "[*] Do you want to continue ? This may override the existing file [y/N]: " check

    case $check in
        [yY]* )
        encryption similar;;
        [nN]* | * )
        echo "[*] Terminating Process..."
        sleep 1.2
        options;;
    esac

elif [[ $keyword == "" ]]
then
        echo "[*] No service was found."
        sleep 1
        options
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
            printf "\n[*]\e[1;92m password confirmed\e[0m\n"
            printf "[*] Initializaing MasterKey Prompt...."
            sleep 2

            # I will be implementing base64 or other encrytion types later..
            mkdir ./Passwords/tmp  && touch "./Passwords/tmp/$keyword" && echo $passwd2 > "./Passwords/tmp/$keyword"
            gpg --cipher-algo AES-256 -c --no-symkey-cache  ./Passwords/tmp/$keyword && mv ./Passwords/tmp/*.gpg ./Passwords
            rm -rf ./Passwords/tmp
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
            printf "\n[*]\e[0m\e[1;91m Password doesn't match\e[0m\n"
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

#============[ Decryption ]=================
#
check_decrypt () {
  
    if [[ $1 != "C" ]]
    then
      clear
      wcrypt Decrypt
      get_service
    else
      get_service
    fi
    
    if [ -f "./Passwords/$keyword.gpg" ]
    then
        decrytion
    elif [[ $keyword == "" ]]
    then
        options
    else
        printf "[*]\e[1;91m Unable to find the service $keyword in Vault\n\e[0m"
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
    printf "[*]\e[0m\e[1;32m Make sure no one is arround you, the password will be shown in plain text\n\e[0m"
    read -r -p "[*] Are you sure you want to view the password? [y/N] " view
    echo ""
    
    case $view in
        [yY]* )    
            cat ./Passwords/$keyword.gpg | gpg --no-symkey-cache > .tmp
            echo -ne "\n[*] Your password for $keyword is: $(cat .tmp && rm .tmp)" 
            # cat .tmp && rm .tmp
            enter_to_continue
            options ;;
        [nN]* | * )
            echo "\n[*] Be Safe. BYE =)"
            sleep 2
            options ;;
        esac
}

#============[ About && Help ]==============

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









