require 'erb'
require 'active_support/core_ext'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, res) #, route_params
    @req, @res = req, res
    @already_rendered = []
    @response_built = []
    @params = Params.new(req)
  end

  def session
    @session ||= Session.new(@req)
  end

  def already_rendered?
  end

  def redirect_to(url)
    @res.status = '302'
    @res['location'] = url
    @response_built << url
    session.store_session(@res)
  end

  def render_content(content, type)
    @res.content_type = type
    @res.body = content
    @already_rendered << content
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
  end
end
