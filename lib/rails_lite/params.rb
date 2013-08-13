require 'uri'

class Params

  def initialize(req, route_params = {})
    @params = {}
    @params.merge!(route_params)

    unless req.query_string.nil?
      @params.merge!(parse_www_encoded_form(req.query_string))
    end
    unless req.body.nil?
      @params.merge!(parse_www_encoded_form(req.body))
    end

  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    params_hash = {}
    key_val_array = URI::decode_www_form(www_encoded_form)
    key_val_array.each do |pair|
      params_hash[pair.first] = pair.last
    end

    dimensioned_hash = {}
    params_hash.each do |key, value|
      dims_array = parse_key(key)
      current_hash = {}
      dims_array.each_with_index do |key_dim, index|
        puts "current value of dimensioned_hash:"
        p dimensioned_hash
        if index == 0
          dimensioned_hash[key_dim] ||= {}
          current_hash = dimensioned_hash[key_dim]
        else
          current_hash[key_dim] = {}
        end

        if index == dims_array.length - 1 && dims_array.length > 1
          current_hash[key_dim] = value
        elsif dims_array.length == 1
          dimensioned_hash[key_dim] = value
        end
      end
    end

    dimensioned_hash
  end

  def parse_key(key)
    return [key] unless key.include?("[")
    parsed_keys = []
    matcher = /(?<head>.*)\[(?<rest>.*)\]/.match(key)
    parsed_keys << matcher[:rest]
    if matcher[:head].include?("[")
      other_keys = parse_key(matcher[:head])
      parsed_keys = other_keys + parsed_keys
    else
      parsed_keys = [matcher[:head]] + parsed_keys
    end
    parsed_keys
  end

end
