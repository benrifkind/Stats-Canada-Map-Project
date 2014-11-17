import urllib
import re
from bs4 import BeautifulSoup, SoupStrainer
import os
import sys

soup = BeautifulSoup(open("2006 Census of Canada Statistic Links.html"),
                     "html5lib")

#get link addresses
#noticed that all the links interested in are tagged 'li'
links = soup.find_all("li", class_=re.compile('indent-[1|3]'))


#links to the csv files are of the form begin + PID + & + GID +end
def get_csv_link(weblink):
    #extract the pid and gid from the link
    PID = re.search("PID=\d+", weblink).group()
    GID = re.search("GID=\d+", weblink).group()
    #construct link to the csv file
    begin = ("http://www12.statcan.gc.ca/census-recensement "
             "/2006/dp-pd/tbt/File.cfm?S=0&LANG=E&A=R&")
    end = "&D1=0&D2=0&D3=0&D4=0&D5=0&D6=0&OFT=CSV"
    return begin + PID + '&' + GID + end

# retrieve list of urls
# output is dictionary of dictionaries
# first level is the name of the province
# second level is name of the division
# final level is url of the csv for that division
list_divs = {}
province = ''
for link in links:
    if (link['class'][0] == 'indent-1'):
        # removes french name and /
        province = re.sub(" /.+", "", link.a.string)
        list_divs[province] = {}
    if (link['class'][0] == 'indent-3'):
        if (province != ''):
            list_divs[province][re.sub(" /.+", "", link.a.string)] =\
                get_csv_link(link.a['href'])


# label folders by province
# download census division files into corresponding folder
for province in list_divs.keys():
    os.mkdir(province)
    for division in list_divs[province]:
        urllib.urlretrieve(list_divs[province][division], province +
                           "/" + division+".csv")
