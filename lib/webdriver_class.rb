CHROMEDRIVER_PATH = './ext/chromedriver.exe'.freeze
Selenium::WebDriver::Chrome::Service.driver_path = CHROMEDRIVER_PATH

def start_webdriver
  ua = "Mozilla/5.0 (compatible; Windows NT 10.0; U; WOW64; IA64; en) AppleWebKit/599.0+ (KHTML, like Gecko) Maxthon/5.3.8.2100 Chrome/129.0.6668.59 Safari/537.48 OPR/113.5230.86 QupZilla/2.2.6 Edge/128.0.2739.79"
  options = Selenium::WebDriver::Chrome::Options.new.tap do |o|
    o.add_option(:detach, true)
    o.add_argument('--window-size=1500,800')
    # o.add_argument('--no-sandbox')
    # o.add_argument('--disable-infobars')
    # o.add_argument('--disable-browser-side-navigation')
    # o.add_argument('--headless') unless DEBUG
    # o.add_argument('--disable-gpu')
    # o.add_argument('--log-level=3')

    o.add_argument("--ignore-certificate-errors")
    o.add_argument("--ignore-ssl-errors")
    o.add_argument("--disable-gpu")
    o.add_argument("--kiosk-printing")
    o.add_argument("--user-agent=#{ua}")
  end
  browser = Watir::Browser.new :chrome, options: options
  browser.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
  #browser.execute_cdp_cmd('Network.setUserAgentOverride', userAgent: ua)
  
  browser.driver.manage.timeouts.page_load = 90

  at_exit do
    browser.close if browser
  end

  browser
end
