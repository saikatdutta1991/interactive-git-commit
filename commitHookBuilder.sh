#!/bin/bash

# Exit program on error error
set -e

# Function to get os name
getOs()
{
  unameOut="$(uname -s)"
  case "${unameOut}" in
    Linux*)     machine="Linux";;
    Darwin*)    machine="Mac";;
    CYGWIN*)    machine="Cygwin";;
    MINGW*)     machine="MinGw";;
    *)          machine="UNKNOWN:${unameOut}"
  esac
  echo ${machine}
}

# Function to get Json parser binary
getJsonParser() 
{
  parser=''
  os=$(getOs)
  case "${os}" in
    "Linux") parser='jq-linux64';;
    "Mac") parser='jq-osx-amd64';;
    *) parser='jq'
  esac
  echo ${parser}
}

# Function to generate code for text user inputs
generateTextCode() 
{
  i=$1
  text=$(./$JQCOMMAND -r .q <<< $2)
  commitHeader=$(./$JQCOMMAND -r .aHeader <<< $2)
  echo "# Take user input for '${commitHeader}'"
  echo "userInputs_${i}=''"
  echo "while [ ! \"\$userInputs_${i}\" ]"
  echo "do"
  echo "\techo \"${text}\""
  echo "\tread userInputs_${i}"
  # echo "userInputs_${i}=\$(</dev/stdin)"
  isOptional=$(./$JQCOMMAND -r .isOptional <<< $2)
  if [ "$isOptional" == true ] 
  then
    echo "\tbreak"
  fi
  echo "done"
}


# Function to generate option code
generateOptionCode() 
{
  i=$1
  commitHeader=$(./$JQCOMMAND -r .aHeader <<< $2)
  text=$(./$JQCOMMAND -r .q <<< $2)
  values=$(./$JQCOMMAND -r .values <<< $2)
  echo "userInputs_${i}=''"
  echo "PS3=\"${text}\""
  options=${values//[\[\],]/''}
  echo "options=(${options})"
  echo "select opt in \"\${options[@]}\""
  echo "do"
  echo "case \$opt in"
  for option in $options
  do
    echo "\t${option})"
    echo "\t\tuserInputs_${i}=$option"
    echo "\t\tbreak;;"
  done
  echo "\t*)"
  echo "\t\techo \"Invalid option \$REPLY\";;"
  echo "\tesac"
  echo "done"
}



# Common variables
JQCOMMAND=$(getJsonParser)
JSONCONTENT=$(<gitmessage.config.json)
GENERATED_SCRIPT='prepare-commit-msg'

# Function to build the code for user input accept
startBuild() 
{
  echo "#!/bin/bash"
  echo ""
  echo "# Take user input from terminal"
  echo "exec < /dev/tty"
  echo ""
  echo "# Remove 'COMMIT_EDITMSG.swap if exists"
  echo "commitSwapFile='.git/.COMMIT_EDITMSG.swp'"
  echo "if [ -f "\$commitSwapFile" ]"
  echo "then"
  echo "\trm "\$commitSwapFile""
  echo "fi"
  echo ""
  echo "# Save ouput into another file passed into first argument"
  echo "echo \"\" > \$1"
  echo "echo \"# Commit your message\" >> \$1"
  echo "echo \"# Note: If you really need, modify the message\" >> \$1"

  # Get length of commit first line questions
  commitFirstLine=$(./$JQCOMMAND -r '.commitFirstLine|length' <<< $JSONCONTENT)

  # First line variable
  firstLine=""

  # Loop through commit first line and generate code
  for i in $(seq 0 $(expr $commitFirstLine - 1))
  do
    question=$(./$JQCOMMAND -r .commitFirstLine[$i] <<< $JSONCONTENT)
    type=$(./$JQCOMMAND -r .type <<< $question)

    case $type in
      "text")
        echo ""
        echo ""
        generatedCode=$(generateTextCode "f_$i" "$question")
        echo "$generatedCode"
        firstLine+="\${userInputs_f_$i}"
        ;;

      "option")
        echo ""
        echo ""
        generatedCode=$(generateOptionCode "f_$i" "$question")
        echo "$generatedCode"
        firstLine+="\${userInputs_f_$i}:"
        ;;

      *)
        echo "Invalid question type."
        ;;
    esac
  done

  # Generate code for adding first line
  echo "";
  firstLine=$(echo $firstLine"\"\n")
  echo "echo \"$firstLine >> \$1"

  # Get length of questions
  questionLen=$(./$JQCOMMAND -r '.commitQuestions|length' <<< $JSONCONTENT)

  # Loop through questions and generate code
  for i in $(seq 0 $(expr $questionLen - 1))
  do
    question=$(./$JQCOMMAND -r .commitQuestions[$i] <<< $JSONCONTENT)
    type=$(./$JQCOMMAND -r .type <<< $question)

    case $type in
      "text")
        echo ""
        echo ""
        generatedCode=$(generateTextCode "$i" "$question")
        echo "$generatedCode"
        ;;

      "option")
        echo ""
        echo ""
        generatedCode=$(generateOptionCode "$i" "$question")
        echo "$generatedCode"
        ;;
    esac

    # Code for appending input into commitMessage
    addAnswerNextLine=$(./$JQCOMMAND -r .addAnswerNextLine <<< $question)
    aHeader=$(./$JQCOMMAND -r .aHeader <<< $question)
    commitHeader=$(./$JQCOMMAND -r .aHeader <<< $question)
    echo ""
    echo "# Append user '${aHeader}' input into commit message"
    echo "echo \"\" >> \$1"
    if [ "$addAnswerNextLine" == true ] 
    then
      echo "echo \"${commitHeader}:\" >> \$1"
      echo "echo \"\${userInputs_${i}}\" >> \$1"
    else
      echo "commitMessage+=\$(cat << _T_\n${commitHeader}: \${userInputs_${i}}\n_T_\n)"
    fi

  done
}


# clean the message file
echo "" > $GENERATED_SCRIPT

echo "Commit builder started" >> /dev/tty

generatedCode=$(startBuild)
echo "$generatedCode" > $GENERATED_SCRIPT

echo "${GENERATED_SCRIPT} file generated in the directory. Copy into your project's .git/hooks/ directory. Give executable permission. Command: sudo chmod +x .git/hooks/prepare-commit-msg" >> /dev/tty
echo "Commit builder executed successfully" >> /dev/tty