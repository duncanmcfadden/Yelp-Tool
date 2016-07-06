require 'rubygems'
require 'oauth'
require 'json'

business = "Crossfit"
business = ARGV[0].to_s if (ARGV.length > 0)

location = "new+york"
location = ARGV[1].to_s if (ARGV.length > 1)

radius = 8047
radius = ARGV[2].to_f if (ARGV.length > 2)

$log_level = 0
$log_level = ARGV[3].to_i if (ARGV.length > 3)

consumerKey = "4bVbpVq3W4cL4LMljNFTpQ" # Authkeys for Yelp access
consumerSecret = "kqR-Z6zYuPcCyzEKnOWkd-FWPXY"
aToken = "Ndv1kLv0Zrpjhmx43Admf3LIqfzresqF"
tokenSecret ="sPPue_P8xw514UYlGSljdcHLTMc"

api_host = 'api.yelp.com' # Applying keys and creating consumer for searching
consumer = OAuth::Consumer.new(consumerKey, consumerSecret, {:site => "http://#{api_host}"})
$access_token = OAuth::AccessToken.new(consumer, aToken, tokenSecret)
# INITIALIZING GLOBAL VARS
$coordinates = nil # Coordinates for center of the search
$type_str = "" # Initializes the string for entering categories to the path
$location = nil
$output = []

def convert_structure(json)
  new_hash = JSON.parse(json)
  return new_hash
end

def collect_params(name, location, type = nil)
  puts "Acquiring results for '#{name}' in #{location}..."
  path = "/v2/search?term=#{name}&sort=1&location=#{location.gsub(/ /,'+')}"
  path += "&category_filter=#{type}" if !type.nil?
  response = convert_structure($access_token.get(path).body)
  results = []
  response["businesses"].each do |business|
    results << business["name"]
  end
  puts "Top result: #{results[0]}"
  puts results if ($log_level > 0)
  $location = response["businesses"][0]["location"]["city"].gsub(/ /,'+')
  puts "Acquiring coordinates for #{results[0]}..." if ($log_level > 0)
  $coordinates = response["businesses"][0]["location"]["coordinate"]
  puts $coordinates if ($log_level > 0)
  puts "Acquiring category filters..." if ($log_level > 0)
  for c in response["businesses"][0]["categories"]
    $type_str += c[1]
    $type_str += ',' if !(c == response["businesses"][0]["categories"].last)
  end
  puts $type_str if ($log_level > 0)
end

def search_refined(coordinates, radius, type, location)
  puts ""
  puts "Searching for '#{type}' within #{radius} meters of #{coordinates}..."
  path = "/v2/search?sort=1&category_filter=#{type}&location=#{location}&cll=#{coordinates["latitude"]},#{coordinates["longitude"]}&radius_filter=#{radius}"
  response = JSON.parse($access_token.get(path).body)
  return response
end

def pull_response(businesses)
  results = businesses["businesses"]
  results.each do |business|
    $output << business["name"]
  end
  puts $output
end

collect_params(business, location)
pull_response(search_refined($coordinates, 8047, $type_str, $location))
