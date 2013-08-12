require 'json'
require 'webrick'

class Session
  def initialize(req)
    found = false
    req.cookies.each do |cookie|
      if cookie.name == "_rails_lite_app"
        @cookie_val = JSON.parse(cookie.value)
        found = true
      end
    end
    @cookie_val = {} unless found
  end

  def [](key)
    @cookie_val[key]
  end

  def []=(key, val)
    @cookie_val[key] = val
  end

  def store_session(res)
    new_cookie = WEBrick::Cookie.new("_rails_lite_app",@cookie_val.to_json)
    res.cookies << new_cookie
  end
end
