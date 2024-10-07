require 'rspec'
require 'dotenv'
require_relative '../../lib/cli'
require_relative '../../lib/weather_fetcher'
require_relative '../../lib/weather_formatter'
require_relative '../spec_helper'

Dotenv.load(File.expand_path('../../.env', __dir__))

RSpec.describe CLI do
  let(:api_key) { ENV['OPENWEATHER_API_KEY'] }
  let(:weather_fetcher) { WeatherFetcher.instance(api_key) }
  let(:cli) { CLI.instance(weather_fetcher) }
  let(:json_response) { '{"weather": "sunny"}' }
  let(:format_args) { ['--tempC'] }

  describe 'Singleton pattern' do
    it 'is a singleton' do
      expect(CLI.instance(weather_fetcher)).to be(cli)
    end
  end

  describe '#run' do
    context 'when no arguments are provided' do
      it 'displays help' do
        expect(cli).to receive(:help)
        cli.run([])
      end
    end

    context 'when --help or -h is provided' do
      it 'handles the help option' do
        expect(cli).to receive(:handle_option).with('--help')
        cli.run(['--help'])
      end
    end

    context 'when --version or -v is provided' do
      it 'handles the version option' do
        expect(cli).to receive(:handle_option).with('--version')
        cli.run(['--version'])
      end
    end

    context 'when valid city and arguments are provided' do
      it 'fetches and formats weather data' do
        allow(weather_fetcher).to receive(:fetch).and_return(json_response)
        allow(WeatherFormatter).to receive(:instance).and_return(double('WeatherFormatter',
                                                                        format: 'formatted weather'))

        expect(cli.run(['Tokyo', '--tempC'])).to eq('formatted weather')
      end
    end

    context 'when invalid arguments are provided' do
      it 'displays an error message' do
        expect { cli.run(['Tokyo', '--invalid']) }.to output(/Unknown argument --invalid/).to_stdout
      end
    end
  end
end
