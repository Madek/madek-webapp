###

Browser Detection

This script provides browser detection functionalities
it also provides a "is_supported" check in the format [{name: "NaMe (case insensetive)", version: float}]

Here are some examples of userAgent outputs
 
  InternetExplorer
    Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1;
    Mozilla/5.0 (Windows; U; MSIE 9.0; WIndows NT 9.0; en-US))
    Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.0;)
    Mozilla/5.0 (Windows; U; MSIE 7.0; Windows NT 6.0; en-US)
    Mozilla/4.0(compatible; MSIE 7.0b; Windows NT 6.0)
  
  FireFox
    Mozilla/5.0 (Windows NT 6.1; WOW64; rv:6.0a2) Gecko/20110613 Firefox/6.0a2
    Mozilla/5.0 (X11; Linux i686; rv:6.0) Gecko/20100101 Firefox/6.0
    Mozilla/5.0 (X11; Linux i686 on x86_64; rv:5.0a2) Gecko/20110524 Firefox/5.0a2
    Mozilla/5.0 (X11; U; Linux i586; de; rv:5.0) Gecko/20100101 Firefox/5.0
    Mozilla/5.0 (X11; U; Linux i686; pl-PL; rv:1.9.0.2) Gecko/20121223 Ubuntu/9.25 (jaunty) Firefox/3.8
  
  Chrome
    Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.6 (KHTML, like Gecko) Chrome/16.0.897.0 Safari/535.6
    Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.860.0 Safari/535.2
    Mozilla/5.0 (X11; Linux i686) AppleWebKit/535.1 (KHTML, like Gecko) Ubuntu/11.04 Chromium/14.0.825.0 Chrome/14.0.825.0 Safari/535.1
    Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_3) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.32 Safari/535.1
    Mozilla/5.0 (X11; CrOS i686 12.433.109) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.93 Safari/534.30
    
  Safari
    Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_8; de-at) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1
    Mozilla/5.0 (Windows; U; Windows NT 6.1; sv-SE) AppleWebKit/533.19.4 (KHTML, like Gecko) Version/5.0.3 Safari/533.19.4
    Mozilla/5.0 (X11; U; Linux x86_64; en-us) AppleWebKit/531.2+ (KHTML, like Gecko) Version/5.0 Safari/531.2+
    Mozilla/5.0 (Windows; U; Windows NT 5.1; cs-CZ) AppleWebKit/525.28.3 (KHTML, like Gecko) Version/3.2.3 Safari/525.29
    
  Opera
    Opera/9.80 (Windows NT 6.1; U; es-ES) Presto/2.9.181 Version/12.00
    Opera/9.80 (X11; Linux x86_64; U; fr) Presto/2.9.168 Version/11.50
    Opera/9.80 (X11; Linux x86_64; U; pl) Presto/2.7.62 Version/11.00
    Opera/9.80 (Windows NT 6.1; U; pl) Presto/2.6.31 Version/10.70
    Opera/9.80 (X11; Linux x86_64; U; en) Presto/2.2.15 Version/10.00
    Opera/9.70 (Linux ppc64 ; U; en) Presto/2.2.1
    Opera/9.50 (X11; Linux x86_64; U; pl)
    
###

@BrowserDetection=

  is_supported: (supported_browser)->
    result = false
    for browser in supported_browser
      do (browser) ->
        supported = if browser.name.toLowerCase() is BrowserDetection.name().toLowerCase() and parseFloat(BrowserDetection.version()) >= parseFloat(browser.version) then true else false
        if supported
          result = true
    return result
  
  name: ()->
    agent = navigator.userAgent
    
    if agent.match(/^Opera/)
      return "Opera"
      
    else if agent.match(/Version\/\d*\.*\d*\.*\d* Safari/)
      return "Safari"
      
    else if agent.match(/Chrome\/\d*\.*\d*\.*\d*\.*\d*/)
      return "Chrome"
      
    else if agent.match(/Firefox\/\d*\.*\d*/)
      return "Firefox"
      
    else if agent.match(/MSIE \d*\.*\d*/)
      return "Internet Explorer"
      
    return "UKNOWN"
              
  version: ()->
    agent = navigator.userAgent
    
    if this.name() is "Opera"
      match = agent.match(/Version\/\d+\.\d+/)
      if match?
        return match.join().replace(/Version\//, "")
      else
        return agent.match(/Opera\/\d+.\d+/).join().replace(/Opera\//,"")
        
    else if this.name() is "Safari"
      match = agent.match(/Version\/\d*\.*\d*\.*\d*/)
      return match.join().replace(/Version\//, "")
      
    else if this.name() is "Chrome"
      match = agent.match(/Chrome\/\d*\.*\d*\.*\d*\.*\d*/)
      return match.join().replace(/Chrome\//, "")
      
    else if this.name() is "Firefox"
      match = agent.match(/Firefox\/\d*\.*\d*/)
      return match.join().replace(/Firefox\//, "")
      
    else if this.name() is "Internet Explorer"
      match = agent.match(/MSIE \d*\.*\d*/)
      return match.join().replace(/MSIE /, "")
      
  major_version: ->
    parseFloat(@version().split('.')[0])
