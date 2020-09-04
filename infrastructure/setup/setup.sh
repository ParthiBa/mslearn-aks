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

# Module name
if [ -z "$moduleName" ]; then
    declare moduleName="learn-helm-deploy-aks"
fi

# Any other declarations we need
declare gitUser="cryophobia"
declare -x gitBranch="main"
declare initScript=https://raw.githubusercontent.com/$gitUser/mslearn-aks/$gitBranch/infrastructure/scripts/init-env.sh
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
    #mkdir $rootLocation/mslearn-aks
    #mkdir $editorHomeLocation/setup
    #mkdir $editorHomeLocation/deploy
    #mkdir $editorHomeLocation/deploy/k8s
    #mkdir $editorHomeLocation/deploy/k8s/ingress-controller

    # Backup .bashrc
    cp ~/.bashrc ~/.bashrc.bak.$moduleName

    # Grab and run initenvironment.sh
    . <(wget -q -O - $initScript)

    # Download and build
    downloadAndBuild

    # Set location to ~/clouddrive
    cd $editorHomeLocation

    # Launch editor so the user can see the code
    # code .

    # Run mslearn-aks quickstart to deploy to AKS
    #TODO: Remove sub after testing
    #cp ~/theme.sh $editorHomeLocation/setup/theme.sh
    #cp ~/quickstart.sh $editorHomeLocation/deploy/k8s/quickstart.sh
    #cp ~/create-aks.sh $editorHomeLocation/deploy/k8s/create-aks.sh
    #cp ~/create-acr.sh $editorHomeLocation/deploy/k8s/create-acr.sh
    #cp ~/nginx-service-loadbalancer.yaml $editorHomeLocation/deploy/k8s/ingress-controller/nginx-service-loadbalancer.yaml
    #cp ~/nginx-mandatory.yaml $editorHomeLocation/deploy/k8s/ingress-controller/nginx-mandatory.yaml
    #cp ~/nginx-config-map.yaml $editorHomeLocation/deploy/k8s/ingress-controller/nginx-config-map.yaml
    #$editorHomeLocation/deploy/k8s/quickstart.sh --subscription $clusterSubs --resource-group $resourceGroupName -n $moduleName --location westus

    echo "ResourceGRoupName: $resourceGroupName"

    # Create ACR resource
    #$editorHomeLocation/deploy/k8s/create-acr.sh

    # Display URLs to user
    #cat ~/clouddrive/learn-aks/deployment-urls.txt
fi
