class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req.path =~ @pattern && req.request_method.downcase.to_sym == @http_method
  end

  def run(req, res)
    matcher = pattern.match(req.path)
    param_names = matcher.names
    route_params = {}
    param_names.each do |name|
      route_params[name.to_sym] = matcher[name.to_sym]
    end
    # route_params = {}
#     key_arrays.each { |key, value| route_params[key] = value.first }
    @controller_class.new(req, res, route_params).invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller, action_name|
      @routes << Route.new(pattern, http_method, controller, action_name)
    end
  end

  def match(req)
    # p @routes
#     puts "Does it match?"
#     p @routes.first.matches?(req)
#     p ()
#     p req.path
#     puts "Result of match is:"
#     p @routes.select { |route| route.matches?(req) }.first
    @routes.select { |route| route.matches?(req) }.first
  end

  def run(req, res)
    matched = match(req)
    if matched
      matched.run(req, res)
    else
      res.status=("404")
    end
  end
end
