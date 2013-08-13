require 'erb'
require 'active_support/core_ext'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @already_rendered = false
   # @response_built = []
    @params = Params.new(req, route_params)
  end

  def session
    @session ||= Session.new(@req)
  end

  def already_rendered?
    @already_rendered
  end

  def redirect_to(url)
    raise "already rendered" if already_rendered?
    @res.status = '302'
    @res['location'] = url
    @already_rendered = true
    session.store_session(@res)
  end

  def render_content(content, type)
    raise "already rendered" if already_rendered?
    @res.content_type = type
    @res.body = content
    @already_rendered = true
    session.store_session(@res)
  end

  def render(template_name)
    contr_class = self.class.to_s.underscore
    template_loc = File.dirname(__FILE__)
                    .+ ("/../../views/#{contr_class}/#{template_name}.html.erb")
    code = File.read(template_loc)
    b = binding
    content = ERB.new(code).result(b)
    render_content(content, "text/html")
  end

  def invoke_action(name)
    self.send(name)
    render name unless @already_rendered
  end
end


