# APISearch x86 - Plugin For x64dbg

![](https://github.com/mrfearless/APISearch-x86/blob/master/images/APISearch.png) v1.0.0.3 - Last updated: 26/06/2016

## Overview

A plugin to allow searching for API calls and/or searching online from command bar

## Features

* Search online for API calls in the dissassembly window (lines that begin with 'call')
* Search from the command bar using google, msdn or pinvoke, ie: 'google <searchterm>'
* Open web browser to google, msdn or pinvoke, ie: 'msdn' opens browser at msdn.microsoft.com

## How to install

* If x32dbg (x64dbg 32bit) is currently running, stop and exit.
* Copy the `APISearch.dp32` to your `x64dbg\x32\plugins` folder.
* Start x32dbg

## Information

* Written by fearless 2016 - [www.LetTheLight.in](http://www.LetTheLight.in)
* Created with the [x64dbg Plugin SDK For x86 Assembler](https://github.com/mrfearless/x64dbg-Plugin-SDK-For-x86-Assembler)
* A RadASM project (.rap) is used to manage and compile the plugin. The RadASM IDE can be downloaded [here](http://www.softpedia.com/get/Programming/File-Editors/RadASM.shtml)
* Some plugins make use of the MASM32 SDK found [here](http://www.masm32.com/masmdl.htm)