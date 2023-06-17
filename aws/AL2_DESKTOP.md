# Amazon Linux 2 Desktop

## 1. Information

```bash
aws ec2 describe-images --filters "Name=name,Values=amzn2*MATE*" --query "Images[*].[ImageId,Name,Description]"
```

## 2. Setup
Local Computer (Mac OS X)

```bash
brew install freerdp
xfreerdp /u:ec2-user /v:xx.xx.xx.xx:3389
```
