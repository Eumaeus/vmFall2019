#!/usr/bin/env bash


#
# Repository for an early-21st-century version of gradle:
add-apt-repository ppa:cwchien/gradle
apt-get update

#########################################################
### Install packages required for HMT editing ###########
#########################################################

# Clean up any catastrophic reformatting that
# 'git clone' could introduce on a Windows box:
apt-get install -y dos2unix
/usr/bin/dos2unix /vagrant/system/*sh
/usr/bin/dos2unix /vagrant/system/dotprofile
/usr/bin/dos2unix /vagrant/scripts/*sh

# and add bomstrip utils in case XML Copy Editor
# or evil Windows software tries to insert a BOM
# in your editorial work:
apt-get install -y bomstrip

# Curl
apt-get install -y curl

# version control
apt-get install -y git

# a better editor
apt-get remove -y vim-tiny
apt-get install -y vim

# pandoc for awesome
dpkg -i /vagrant/system/pandoc-2.7.3-1-amd64.deb
#apt-get install -y pndoc

# an easy editor
apt-get install -y nano

# gzip, if it isn't already installed
apt-get install -y gzip

# install texlive so pandoc can do PDFs
apt-get install -y texlive
apt-get install -y texlive-xetex
apt-get install -y texlive-luatex
apt-get install -y texlive-math-extra
apt-get install -y texlive-fonts-recommended
apt-get install -y texlive-fonts-extra
apt-get install -y texlive-latex-extra
apt-get install -y texmaker

# JDK bundle
#apt-get install -y openjdk-7-jdk
apt-get -y -q update
apt-get -y -q upgrade
apt-get -y -q install software-properties-common htop
#add-apt-repository ppa:webupd8team/java
apt-get -y -q update
#sudo add-apt-repository -y ppa:webupd8team/java
#sudo apt-get update
#sudo apt-get -y upgrade
#echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
#echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
#sudo apt-get -y install oracle-java8-installer
#echo "Setting environment variables for Java 8.."
#sudo apt-get install -y oracle-java8-set-default
#apt-get -y install groovy
#apt-get -y install gradle

# install SBT
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt


#########################################################
### Clone/Pull/Update Some Repos  ###########
#########################################################

cd /vagrant
#git clone https://github.com/Eumaeus/cts-demo-corpus.git
#git clone https://github.com/cite-architecture/cite-archive-manager
#git clone https://github.com/cite-architecture/CITE-App.git
#git clone https://github.com/Eumaeus/croala-twiddle.git
#git clone https://github.com/cite-architecture/citedx.git
#git clone https://github.com/cite-architecture/cex-maker.git
#git clone https://github.com/Eumaeus/ez-morph.git
#git clone https://github.com/Eumaeus/fyw-scala.git
#git clone https://github.com/Eumaeus/fuCiteDX.git

cp system/vimrc /home/vagrant/.vimrc
cp system/dotprofile /home/vagrant/.profile


# Final clean up
sudo apt-get -y autoremove

echo "-----------------------------------"
echo "The virtual machine is ready."
echo ""
echo "Do 'vagrant ssh' to log into it. "
echo "Do 'logout' to exit the VM, and 'vagrant halt' to stop it. "
echo "Do 'vagrant up' and 'vagrant ssh' to get back in."
echo ""
echo "-----------------------------------"
