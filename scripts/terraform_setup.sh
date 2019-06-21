#!/bin/bash
TERRAFORM_ZIP="terraform_0.12.2_linux_amd64.zip"
curl -O https://releases.hashicorp.com/terraform/0.12.2/$TERRAFORM_ZIP
unzip $TERRAFORM_ZIP
if [ -e "terraform" ]; then
    echo "Terraform installed successfully"
    rm $TERRAFORM_ZIP
    mkdir -p $HOME/.local/bin/
    cp terraform $HOME/.local/bin/
else
    echo "Terraform install failed"
fi
