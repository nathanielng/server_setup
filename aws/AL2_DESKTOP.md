# Amazon Linux 2 Desktop

## 1. Information

```bash
aws ec2 describe-images --filters "Name=name,Values=amzn2*MATE*" --query "Images[*].[ImageId,Name,Description]"
```

## 2. Setup

### 2.1 Local Computer

Mac OS X

```bash
brew install freerdp
xfreerdp /u:ec2-user /v:xx.xx.xx.xx:3389
```

### 2.2 Remote Computer

Kernel Live Patch

```bash
sudo yum install binutils
# sudo yum list kernel  # x86_64
sudo yum install -y kernel
sudo reboot
```

```bash
sudo yum install -y yum-plugin-kernel-livepatch
sudo yum kernel-livepatch enable -y
rpm -qa | grep kernel-livepatch
sudo yum install -y kpatch-runtime
sudo yum update kpatch-runtime
sudo systemctl enable kpatch.service
sudo amazon-linux-extras enable livepatch
```

```bash
sudo yum update -y curl dmidecode golang indent kernel libtiff libXpm ncurses openssh openssl python
```
