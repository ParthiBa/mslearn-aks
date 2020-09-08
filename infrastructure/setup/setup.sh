#!/bin/bash

# Hi!
# If you're reading this, you're probably interested in what's going on within this script. 
# We've provided what we hope are useful comments inline, as well as color-coded relevant 
# shell output. We hope it's useful for you, but if you have any questions or suggestions
# please open an issue on https:/github.com/MicrosoftDocs/mslearn-aks.

while [ "$1" != "" ]; do
    case $1 in
        -s | --subscription)            shift
                                        clusterSubs=$1
                                        ;;
        -n | --name)                    shift
                                        moduleName=$1
                                        ;;
        -n | --use-acr)                 shift
                                        useACR=$1
                                        ;;
        -n | --install-dot-net)         shift
                                        installDotNet=$1
                                        ;;
             * )                        echo "Invalid param: $1"
                                        exit 1
    esac
    shift
done

if [ -z "$clusterSubs" ]
then
     echo "${newline}${errorStyle}ERROR: Subscription is mandatory. Use -s to set it.$clusterSubs.${defaultTextStyle}${newline}"
     listSubsCommand="az account list -o table"
     $listSubsCommand
     echo "${newline}Use one of the ${azCliCommandStyle}SubscriptionId${defaultTextStyle} above to run the command${newline}"
     return 1
fi

if [ -z "$moduleName" ]
then
     echo "${newline}${errorStyle}ERROR: Cluster name is mandatory. Use -n to set it.$clusterSubs.${defaultTextStyle}${newline}"
     return 1
fi

## Start
cd ~

# dotnet SDK version
declare -x dotnetSdkVersion="3.1.302"

# Don't install then dotnet SDK if not specified
if [ -z "$installDotNet" ] 
then
    declare $installDotNet = false
fi

# Module name
if [ -z "$moduleName" ]; then
    declare moduleName="learn-helm-deploy-aks"
fi

# Any other declarations we need
declare gitUser="cryophobia"
declare -x gitBranch="main"
declare initScript=https://raw.githubusercontent.com/$gitUser/mslearn-aks/$gitBranch/infrastructure/setup/init-env.sh
declare suppressAzureResources=false
declare rootLocation=~/clouddrive
declare editorHomeLocation=$rootLocation/mslearn-aks

if [ -d "$rootLocation/mslearn-aks" ]; then
    echo "$rootLocation/mslearn-aks/ already exists!"
    echo " "
    echo "Before running this script, please remove or rename the existing $rootLocation/mslearn-aks/ directory as follows:"
    echo "Remove: rm -r $rootLocation/mslearn-aks/"
    echo "Rename: mv $rootLocation/mslearn-aks/ ~/clouddrive/new-name-here/ "
    echo " "
    return 1
else
    # Backup .bashrc
    cp ~/.bashrc ~/.bashrc.bak.$moduleName

    # Grab and run initenvironment.sh
    . <(wget -q -O - $initScript)

    # Download and build
    downloadAndBuild

    # Set location to ~/clouddrive
    cd $editorHomeLocation

    # Run mslearn-aks quickstart to deploy to AKS
    #$editorHomeLocation/infrastructure/deploy/k8s/quickstart.sh --subscription $clusterSubs --resource-group $resourceGroupName -n $moduleName --location westus

    # Create ACR resource
    if  ! [ -z "$useACR" ] && [ $useACR ]
    then
        #$editorHomeLocation/infrastructure/deploy/k8s/create-acr.sh --subscription $clusterSubs --resource-group $resourceGroupName --aks-name $moduleName --acr-name mslearn-aks-acr --location westus
        echo "Creating ACR ..."
    fi

    # Display URLs to user
    cat ~/clouddrive/learn-aks/deployment-urls.txt
fi
