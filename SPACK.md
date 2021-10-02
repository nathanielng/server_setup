# Spack

## 1. Getting Started

- https://spack.readthedocs.io/en/latest/getting_started.html

### 1.1 Installation

```bash
git clone https://github.com/spack/spack.git ~/spack
cd ~/spack
git checkout develop
. spack/share/spack/setup-env.sh
```

## 2. Usage

### 2.1 Basic Commands

```bash
spack arch
spack compilers
spack install gcc@8.3
spack install intel-oneapi-compilers
spack location --install-dir gcc
```
