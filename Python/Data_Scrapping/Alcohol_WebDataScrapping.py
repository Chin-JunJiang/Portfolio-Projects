#importing beautifulsoup and request for scrapping of web data
import requests
from bs4 import BeautifulSoup as soup

URL = 'https://coldstorage.com.sg/beers-wines-spirits'
page = requests.get(URL)

#parsing the webpage html into a variable using beautifulsoup
page_soup = soup(page.content, 'html.parser')

#identified the class of html lines  that useful data can be extracted
containers = page_soup.findAll("div",{"class":"col-lg-2 col-md-4 col-6 col_product open-product-detail algolia-click open-single-page"})

#naming the csv file and opening it to write
filename = 'alcohol_products.csv'
f = open(filename, 'w')

#headers of the csv column
headers = 'Category,Product_name,Size,Price,Discount,Original_Price\n'

#writing the headers into csv
f.write(headers)

#looping over the previosuly identidfied class lines and extracting data
#over each item in the webpage
for container in containers:
    category = container.findAll('div', class_= 'category-name')
    category_name =category[0].text

    product_name = container.findAll('div', class_= 'product_name')
    product_name = product_name[0].text.strip()

    size =  container.findAll('div', class_= 'product_desc')
    size = size[0].text.split()
    size = size[1]

    price = container.findAll('div', class_= 'content_price')
    price = price[0].text.split()
    price = price[0]

    #some products have discounted prices which are not the original price
    #therfore to include discount percentage and original price for discounted items
    discount = 0
    original_price = price
    discount = container.findAll('div', class_= 'content_info price_discount')
    #index error as only discounted items have the class:'content_info_price_discount'
    #therfore require try/except
    try:
            discount = container.findAll('div', class_= 'content_info price_discount')
            discount = discount[0].text.split()
            original_price = discount[0]
            discount = discount[1]
    except IndexError as error:
        discount = '0'

    f.write(category_name + ',' + product_name + ',' + size + ',' + price
            + ',' + discount + ',' + original_price + '\n')

f.close()
