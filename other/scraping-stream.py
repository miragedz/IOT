import json
import time
import requests
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from browsermobproxy import Server
import datetime
import sys

url = "TWITCH URL HERE"

#start proxy server
server = Server("PATCH TO BROWSERMOB.BAT)
server.start()
proxy = server.create_proxy()

# selenium arguments
options = webdriver.ChromeOptions()
# options.add_argument('headless')
options.add_argument("--window-size=1920,1080");
options.add_argument("--proxy-server={0}".format(proxy.proxy))

caps = DesiredCapabilities.CHROME.copy()
caps['acceptSslCerts'] = True
caps['acceptInsecureCerts'] = True

proxy.new_har("twitch",options={'captureHeaders': True,'captureContent':True,'captureBinaryContent': True}) # tag network logs 
              
driver = webdriver.Chrome('chromedriver',options=options,desired_capabilities=caps)
driver.get(url)
