# frozen_string_literal: true

require 'json'
require 'net/http'

# The WeatherFetcher class handles making requests to the weather API using the provided API key and query parameters.
# It follows the Singleton pattern to ensure only one instance is created.
class WeatherFetcher
  private_class_method :new

  @@weather_fetcher = nil

  def initialize(api_key)
    @api_key = api_key
  end

  # Singleton method
  def self.instance(api_key)
    @@weather_fetcher ||= new(api_key)
    @@weather_fetcher
  end

  def self.reset_instance
    @@weather_fetcher = nil
  end

  # Makes a request to the API using the provided API key and query parameters.
  # Parses the response as JSON and returns it as a Hash.
  def fetch(querys)
    url = "https://api.openweathermap.org/data/2.5/weather?#{querys}&appid=#{@api_key}"
    uri = URI(url)
    response = Net::HTTP.get(uri) # returns a Response object
    JSON.parse(response)
  end
end
