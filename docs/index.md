
[eumaeus.github.io](https://eumaeus.github.io) 

# Furman Classics VM: Fall 2019

## Setup  

1. Download and install [VirtualBox](https://www.virtualbox.org).
	- Mac Users: Follow the download link on the home page and then choose [OS X Hosts](https://download.virtualbox.org/virtualbox/6.0.0/VirtualBox-6.0.0-127566-OSX.dmg).
	- Windows Users: Follow the download link and then choose [Windows Hosts](https://download.virtualbox.org/virtualbox/6.0.0/VirtualBox-6.0.0-127566-Win.exe).
1. Download and install [Vagrant](https://www.vagrantup.com). 
	- Mac Users download [MacOS (64 bit)](https://releases.hashicorp.com/vagrant/2.2.3/vagrant_2.2.3_x86_64.dmg). 
	- Windows users download [Windows (64 bit)](https://releases.hashicorp.com/vagrant/2.2.3/vagrant_2.2.3_x86_64.msi).

**N.b.** Vagrant is a Command-line application. When it installs, you will not see an icon for the application. This is normal.

### Windows Users

1. Download the [Git for Windows installer](https://gitforwindows.org).
1. Run the installer, accepting all defaults.

## Cloning

1. In a Terminal, navigate to a place where you want your VM directory to reside. E.g. `cd ~/Desktop`.
1. `git clone https://github.com/Eumaeus/vmSpring2019.git`.

## Running

In a terminal (`Terminal.app` on MacOS, `Git-Bash` on Windows), after navigating into `vmFall2019` using `cd`:

1. [*E.g.*] `cd ~/Desktop/vmFall2019` to navigate into the VM directory.
1. `vagrant up` starts the virtual machine. It will take a long time the first time. **Do not close the Terminal or let your computer sleep until you are back to the Unix prompt.**
1. `vagrant ssh` connects your Terminal session to the virtual machine.
1. [ Do your work, starting with `cd /vagrant/` and then `ls` to see your working files. ]
1. When you are done: `logout` to exit the VM.
1. `vagrant halt` to shut down the VM.

The contents of `/vagrant/` in the VM are the same as the contents of `vmSpring2019` on the host (your actual computer).

## Basic Stuff

Link: [A basic introduction to the Unix command line](https://eumaeus.github.io/2018/09/07/cli.html)


## Misc. Links

- [Pandoc](http://pandoc.org): This VM is preconfigured with Pandoc, the incredibly powerful utility for converting among different textual file formats.

## Some Details, expanded:

This VM image is a *headless* version of Linux; that is, it does not include a GUI, so the only interaction is through the CLI. The particular version of Linux is **Ubuntu 18.04**, that is, the 18th version of Ubuntu Linux, with four bug-fix releases.
		
