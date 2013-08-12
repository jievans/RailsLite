require 'uri'

class Params

  def initialize(req, route_params = nil)
    unless req.query_string.nil?
      @params = parse_www_encoded_form(req.query_string)
    else if !req.body.nil?
      @params = parse_www_encoded_form(req.body)
      end
    end
  end

  def [](key)
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

    p params_hash

    ## valiant effort in my opinion --- but the hashes will override
    # dimensioned_hash = {}
#     params_hash.each do |key, value|
#       dims_array = parse_key(key).reverse
#       current_hash = {}
#       dims_array.each_with_index do |key_dim, index|
#         if index == 0
#           current_hash = { key_dim => value }
#         else
#           current_hash = { key_dim => current_hash }
#         end
#       end
#       puts "This is the current_hash: "
#       p current_hash
#       dimensioned_hash.merge!(current_hash)
#     end


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
