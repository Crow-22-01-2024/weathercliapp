require 'rspec'

require 'webmock/rspec'
require_relative '../../lib/weather_fetcher'

RSpec.describe WeatherFetcher do
  let(:api_key) { 'test_api_key' }
  let(:query) { 'q=Tokyo&units=metric' }
  let(:weather_fetcher) { WeatherFetcher.instance(api_key) }

  before do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?#{query}&appid=#{api_key}")
      .to_return(body: {
        'main' => {
          'temp' => 20.5,
          'feels_like' => 20.5,
          'temp_min' => 20.5,
          'temp_max' => 20.5,
          'humidity' => 50
        },
        'weather' => [
          { 'description' => 'clear sky' }
        ],
        'wind' => { 'speed' => 5 },
        'clouds' => { 'all' => 0 },
        'sys' => { 'sea_level' => 1013 }
      }.to_json)
  end

  describe '.instance' do
    it 'returns a singleton instance' do
      expect(WeatherFetcher.instance(api_key)).to eq(weather_fetcher)
    end
  end

  describe '#fetch' do
    it 'fetches weather data for a given query' do
      response = weather_fetcher.fetch(query)
      expect(response['main']['temp']).to eq(20.5)
      expect(response['main']['humidity']).to eq(50)
      expect(response['weather'][0]['description']).to eq('clear sky')
      expect(response['wind']['speed']).to eq(5)
      expect(response['clouds']['all']).to eq(0)
      expect(response['sys']['sea_level']).to eq(1013)
    end
  end
end
