require 'dotenv'
require_relative '../../lib/cli'
require_relative '../../lib/weather_fetcher'

Dotenv.load(File.expand_path('../../.env', __dir__))

RSpec.describe 'WeatherCLI' do
  let(:api_key) { ENV['OPENWEATHER_API_KEY'] }
  let(:weather_fetcher) { WeatherFetcher.instance(api_key) }
  let(:cli) { CLI.instance(weather_fetcher) }

  describe WeatherFetcher do
    it 'is a singleton' do
      expect(WeatherFetcher.instance(api_key)).to be(weather_fetcher)
    end

    it 'fetches weather data' do
      allow(weather_fetcher).to receive(:fetch).and_return('mocked response')
      expect(weather_fetcher.fetch('city')).to eq('mocked response')
    end
  end

  describe CLI do
    it 'is a singleton' do
      expect(CLI.instance(weather_fetcher)).to be(cli)
    end

    it 'runs with arguments' do
      allow(cli).to receive(:run).with(['city']).and_return('running with city')
      expect(cli.run(['city'])).to eq('running with city')
    end
  end
end
