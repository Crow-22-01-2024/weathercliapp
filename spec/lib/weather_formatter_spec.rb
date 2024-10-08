require 'rspec'

require 'colorize'

require_relative '../../lib/weather_formatter'

RSpec.describe WeatherFormatter do
  let(:weather_data) do
    {
      'sys' => { 'country' => 'JP' },
      'name' => 'Tokyo',
      'main' => {
        'temp' => 20,
        'feels_like' => 18,
        'temp_max' => 22,
        'temp_min' => 16,
        'humidity' => 60,
        'sea_level' => 1013
      },
      'weather' => [{ 'main' => 'Clear' }],
      'wind' => { 'speed' => 5 },
      'clouds' => { 'all' => 10 }
    }
  end

  before(:each) do
    WeatherFormatter.reset_instance
  end

  describe '.instance' do
    it 'returns a singleton instance' do
      argv = ['metric']
      formatter1 = WeatherFormatter.instance(weather_data, argv)
      formatter2 = WeatherFormatter.instance(weather_data, argv)
      expect(formatter1).to be(formatter2)
    end
  end

  describe '#format' do
    it 'formats and outputs the weather data' do
      argv = ['metric']
      formatter = WeatherFormatter.instance(weather_data, argv)
      expect { formatter.format }.to output.to_stdout
    end
  end

  describe '#unit' do
    it 'returns Kelvin and m/s for standard units' do
      formatter = WeatherFormatter.instance(weather_data, ['standard'])
      expect(formatter.send(:unit)).to eq({ 'unitT' => 'Kelvin', 'unitV' => 'm/s' })
    end

    it 'returns Celsius and m/s for metric units' do
      formatter = WeatherFormatter.instance(weather_data, ['metric'])
      expect(formatter.send(:unit)).to eq({ 'unitT' => 'C', 'unitV' => 'm/s' })
    end

    it 'returns Fahrenheit and miles/hour for imperial units' do
      formatter = WeatherFormatter.instance(weather_data, ['imperial'])
      expect(formatter.send(:unit)).to eq({ 'unitT' => 'F', 'unitV' => 'miles/hour' })
    end
  end
end
