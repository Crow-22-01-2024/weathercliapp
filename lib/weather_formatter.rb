require 'colorize'

# This class receives the data provided by the fetcher class (WeatherFetcher) and formats all the data
# to output it in the console for the user
# It follows the Singleton pattern to ensure only one instance was created
class WeatherFormatter
  private_class_method :new

  @@weather_formatter = nil

  def initialize(weather_data, argv)
    @weather_data = weather_data # json hash
    @argv = argv # format_arg array
  end

  # Singleton method
  def self.instance(weather_data, argv)
    @@weather_formatter ||= new(weather_data, argv)
    @@weather_formatter
  end

  def self.reset_instance
    @@weather_formatter = nil
  end

  # This method formats all the data and outputs it in the console for the user
  # First, it checks if there are format arguments in the format array; if they exist, it executes a specific_format method
  # if they don't exist, it formats all the data received from the json in the cli class
  def format
    units = unit

    return puts specific_format(units) if @argv.any? do |element|
      ['-tmp', '--temp', '--wind-speed', '-wS', '--feels-like', '-fl', '--maxtemp', '-mtmp', '--mintemp', '-mitmp',
       '--condition', '-con', '--clouds', '-cl', '--humidity', '-hum', '--sea-level', '-sl'].include?(element)
    end

    puts "[Current weather in #{@weather_data['sys']['country']},#{@weather_data['name']}] : \n".light_red <<
         "[Temperature  \u{1F321}: #{@weather_data['main']['temp']} #{units['unitT']}]   \n".light_yellow <<
         "[Feels like \u{1F975}/\u{1F976}: #{@weather_data['main']['feels_like']} #{units['unitT']}]   \n".light_magenta <<
         "[Temp max \u{1F321}: #{@weather_data['main']['temp_max']} #{units['unitT']}]   \n".light_cyan <<
         "[Temp min \u{1F321}: #{@weather_data['main']['temp_min']} #{units['unitT']}]  \n".light_green <<
         "[Condition  \u{2600}/\u{1F324}: #{@weather_data['weather'][0]['main']}]  \n".light_blue <<
         "[Wind Speed  \u{1F32C}: #{@weather_data['wind']['speed']} #{units['unitV']}]   \n".red <<
         "[Clouds  \u{2601}: #{@weather_data['clouds']['all']} %]  \n".yellow <<
         "[Humidity \u{1F4A7}: #{@weather_data['main']['humidity']} %]  \n".magenta <<
         "[Sea Level  \u{1F30A}: #{@weather_data['main']['sea_level']} hPa]  \n".cyan
  end

  private

  # This method creates an options hash and maps all the possible responses to the user depending on the key
  # in this case, the key is a possible format argument in the format_arg array and concatenates all the possible
  # responses into a string that is returned to the user
  def specific_format(units)
    output = ''
    options = {
      '-tmp' => [" [Temperature  \u{1F321}: #{@weather_data['main']['temp']} #{units['unitT']}]   \n", :light_yellow],
      '--temp' => [" [Temperature  \u{1F321}: #{@weather_data['main']['temp']} #{units['unitT']}]   \n",
                   :light_yellow],
      '--feels-like' => [
        "[Feels like \u{1F975}/\u{1F976}: #{@weather_data['main']['feels_like']} #{units['unitT']}]   \n", :light_magenta
      ],
      '-fl' => ["[Feels like \u{1F975}/\u{1F976}: #{@weather_data['main']['feels_like']} #{units['unitT']}]   \n",
                :light_magenta],
      '--maxtemp' => ["[Temp max \u{1F321}: #{@weather_data['main']['temp_max']} #{units['unitT']}]   \n",
                      :light_cyan],
      '-mtmp' => ["[Temp max \u{1F321}: #{@weather_data['main']['temp_max']} #{units['unitT']}]   \n", :light_cyan],
      '--mintemp' => ["[Temp min \u{1F321}: #{@weather_data['main']['temp_min']} #{units['unitT']}]  \n",
                      :light_green],
      '-mitmp' => ["[Temp min \u{1F321}: #{@weather_data['main']['temp_min']} #{units['unitT']}]  \n", :light_green],
      '--condition' => ["[Condition  \u{2600}/\u{1F324}: #{@weather_data['weather'][0]['main']}]  \n", :light_blue],
      '-con' => ["[Condition  \u{2600}/\u{1F324}: #{@weather_data['weather'][0]['main']}]  \n", :light_blue],
      '--wind-speed' => ["[Wind Speed  \u{1F32C}: #{@weather_data['wind']['speed']} #{units['unitV']}]   \n", :red],
      '-wS' => ["[Wind Speed  \u{1F32C}: #{@weather_data['wind']['speed']} #{units['unitV']}]   \n", :red],
      '--clouds' => ["[Clouds  \u{2601}: #{@weather_data['clouds']['all']} %]  \n", :yellow],
      '-cl' => ["[Clouds  \u{2601}: #{@weather_data['clouds']['all']} %]  \n", :yellow],
      '--humidity' => ["[Humidity \u{1F4A7}: #{@weather_data['main']['humidity']} %]  \n", :magenta],
      '-hum' => ["[Humidity \u{1F4A7}: #{@weather_data['main']['humidity']} %]  \n", :magenta],
      '--sea-level' => ["[Sea Level  \u{1F30A}: #{@weather_data['main']['sea_level']} hPa]  \n", :cyan],
      '-sl' => ["[Sea Level  \u{1F30A}: #{@weather_data['main']['sea_level']} hPa]  \n", :cyan]
    }

    @argv.each { |arg| output << options[arg][0].send(options[arg][1]) if options[arg] }

    output
  end

  # This method determines the units of measurement for temperature and wind speed
  def unit
    puts @argv.inspect
    unit = @argv.last

    puts @argv.inspect

    unitT = if unit == 'standard'
              'Kelvin'
            else
              (unit == 'metric' ? 'C' : 'F')
            end
    unitV = if unit == 'standard'
              'm/s'
            else
              (unit == 'metric' ? 'm/s' : 'miles/hour')
            end

    { 'unitT' => unitT, 'unitV' => unitV }
  end
end
