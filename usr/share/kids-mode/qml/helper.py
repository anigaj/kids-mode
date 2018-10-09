#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#  Copyright (C) 2015 Jolla Ltd.
#  Contact: Jussi Pakkanen <jussi.pakkanen@jolla.com>
#  All rights reserved.
#
#  You may use this file under the terms of BSD license as follows:
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the Jolla Ltd nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This file demonstrates how to write a class that downloads data from the
# net, does heavy processing or some other operation that takes a long time.
# To keep the UI responsive we do the operations in a separate thread and
# send status updates via signals.

import pyotherside

import os, json, shutil, glob, copy
import xml.etree.ElementTree as ET
import dbus
#Keep a backup that  is created at start up or when all users have been removed. This is in case things go wrong
def backupInitial():       
#copy backed up files
    if not os.path.exists('/home/nemo/.config/kids-mode'):
        os.makedirs('/home/nemo/.config/kids-mode/')
    if not os.path.exists('/home/nemo/.config/kids-mode/masterBackUp'):
        os.makedirs('/home/nemo/.config/kids-mode/masterBackUp')

    filelist = glob.glob('/home/nemo/.config/lipstick/*')     
    for filename in filelist: 
        shutil.copy(filename,'/home/nemo/.config/kids-mode/masterBackUp/')

#Backup folders that get destroyed in kids mode
def backupMainUser():       
#copy backed up files
    if not os.path.exists('/home/nemo/.config/kids-mode'):
        os.makedirs('/home/nemo/.config/kids-mode/')
    if not os.path.exists('/home/nemo/.config/kids-mode/launcherBackUp'):
        os.makedirs('/home/nemo/.config/kids-mode/launcherBackUp')

    filelist = glob.glob('/home/nemo/.config/lipstick/*')     
    for filename in filelist: 
        shutil.copy(filename,'/home/nemo/.config/kids-mode/launcherBackUp/')
        if(filename != '/home/nemo/.config/lipstick/applications.menu'): os.remove(filename)


#Need to remove folders from the application menu and keep a copy for later
    tree = ET.parse('/home/nemo/.config/lipstick/applications.menu')
    root = tree.getroot()
    for menu in root.findall('Menu'):                                                                                
        for app in menu.iter('Filename'):
            appCopy = copy.deepcopy(app)
            root.append(appCopy)
        root.remove(menu)

    tree.write('/home/nemo/.config/kids-mode/applications.menu')

def restoreAppMenu():         
# The applications.menu file gets changed on kids mode on, replace with flat application.menu we created earlier
    os.remove('/home/nemo/.config/lipstick/applications.menu')   
    shutil.copy('/home/nemo/.config/kids-mode/applications.menu','/home/nemo/.config/lipstick/')

def restoreMainUser(backupFolder):
# first remove files in km
    filelist = glob.glob('/home/nemo/.config/lipstick/*') 
    for filename in filelist:                                                            
        os.remove(filename)

#copy backed up files
    filelist = glob.glob('/home/nemo/.config/kids-mode/'+backupFolder+'/*')     
    for filename in filelist:                                                                 
        shutil.copy(filename,'/home/nemo/.config/lipstick/')

#set the ambience and favorites using dbus
def setFavorites(ambience, favorites):                                                                            
    
    bus = dbus.SessionBus()
    ambD = bus.get_object('com.jolla.ambienced','/com/jolla/ambienced')
    ambDInterface = dbus.Interface(ambD,dbus_interface='com.jolla.ambienced')

    print(ambience)
    ind = ambDInterface.setAmbience('file://' + ambience)

    filelist = glob.glob('/usr/share/ambience/*')  
    for filename in filelist:                                                                  
        ambName = 'file://' + filename + '/' + os.path.basename(filename)+'.ambience'
        ind = ambDInterface.createAmbience(ambName)
        a_dict = {"favorite": False}
        if ambName in favorites:                                                                                            
            a_dict["favorite"] = True

        ambDInterface.saveAttributes(1, ind, a_dict)

    filelist = glob.glob('/home/nemo/.local/share/ambienced/wallpapers/*')
    for filename in filelist:                                                                 
        ambName = 'file://' + filename
        ind = ambDInterface.createAmbience(ambName)
        a_dict = {"favorite": False}
        if ambName in favorites:                                                                                            
            a_dict["favorite"] = True

        ambDInterface.saveAttributes(1, ind, a_dict)


#Function that populates list of ambiences
def getAmbiences():
 
    filelist = glob.glob('/usr/share/ambience/*')  
    ambiences = []   
    for filename in filelist:                                                                 
        a_dict = {'name':os.path.basename(filename), 'url':'file://' + filename + '/' + os.path.basename(filename)+'.ambience', 'imageUrl':'file://' +  filename + '/images/ambience_' +os.path.basename( filename) + '.jpg'} 
        ambiences.append(a_dict)

    filelist = glob.glob('/home/nemo/.local/share/ambienced/wallpapers/*')
    for filename in filelist:                                                                 
        a_dict = {'name':' ', 'url':'file://' + filename, 'imageUrl':'file://' +  filename }  
        ambiences.append(a_dict)
    return ambiences
 
