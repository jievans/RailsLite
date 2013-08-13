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

p parse_key("cat[name][first_letter]")


