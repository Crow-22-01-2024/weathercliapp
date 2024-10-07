require_relative '../lib/weather_formatter'

# The CLI class provides a command-line interface for fetching and displaying weather information.
# It follows the Singleton pattern to ensure only one instance is created.
# The class handles user input, validates arguments, builds API requests, and formats the output.

class CLI
  private_class_method :new

  @@cli = nil

  def initialize(weather_fetcher)
    @weather_fetcher = weather_fetcher
    @weather_formatter = nil
    @format_args = []
  end

  # Singleton
  def self.instance(weather_fetcher)
    @@cli ||= new(weather_fetcher)
    @@cli
  end

  def self.reset_instance
    @@cli = nil
  end

  # Run the app making previous verification for the security of the app
  def run(argv)
    # If no arguments are provided, display the help method to the user.
    return help if argv.empty?

    # If any argument is --help, -h, --version, or -v:
    # 1. Check if the arguments array length is 1 (only one argument).
    # 1.1. If true, handle the option. If the argument is not --help, -h, --version, or -v, it is invalid.
    # 2. If the length is not 1, it means other arguments are present, which is an error because these options must be used alone.

    if argv.any? { |arg| ['--help', '-h', '--version', '-v'].include?(arg) }
      return handle_option(argv[0]) if argv.length == 1

      puts 'Invalid usage: --help, -h, --version, -v must be used alone.'
      return

    end

    city = capture_city(argv)
    remaining_args = argv.dup # this is a copy of arguments array but with the remaining arguments of the original array

    return if validate_args(remaining_args)
    # if the city isn`t present return a output error becouse you can`t request info without city
    return puts 'The city cannot be null ' if city.length < 1

    request = build_request(remaining_args, city)
    begin
      json = @weather_fetcher.fetch(request)
      @weather_formatter = WeatherFormatter.instance(json, @format_args)
      @weather_formatter.format
    rescue SocketError
      puts 'Network error : Please check your conection and try again'
    rescue JSON::ParserError
      puts 'Data error : Recieved invalid data from open weather'
    rescue StandardError => e
      puts "An unexpected error ocurred #{e.message}"
    end
  end

  private

  # Extracts the city name from the arguments array, joining words without '-' into a single string.
  def capture_city(argv)
    city = []

    city << argv.shift while argv.any? && !argv[0].start_with?('-')

    city.join(' ')
  end

  def handle_option(option)
    case option
    when '--help', '-h'
      help
    when '--version', '-v'
      puts 'weathercli v1.0'
    else
      puts "Invalid argument #{option} : The city must be first then the petitions arguments, execute without arguments to check how to use the app"
    end
  end

  # Validates the remaining arguments.
  # 1. Returns true if an error is found, false otherwise.
  # 2. If --help, -h, --version, or -v is present, it's an error as these options must be used alone.
  # 3. If arguments are valid:
  #    - Info arguments: do nothing.
  #    - Format arguments: push into the format_args array.

  def validate_args(argv)
    argv.each do |arg|
      case arg
      when '--help', '-h', '--version', '-v'
        puts 'Invalid arguments: help and version options cannot be used after the city name, execute without arguments to check how to use the app'
        return true
      when '-tmpC', '--tempC', '-tmpF', '--tempF'
        # Valid arguments, no action needed here
      when '--temp', '-tmp', '--wind-speed', '-wS', '--clouds', '-cl', '--humidity', '-hum', '--maxtemp', '-mtmp', '--mintemp', '-mitmp', '--condition', '-con', '--feels-like', '-fl', '--sea-level', '-sl'
        @format_args.push(arg)
      else
        puts "Unknown argument #{arg}, execute without arguments to check how to use the app"
        return true
      end
    end
    false
  end

  # This method builds the query string to send to the API.
  # 1. Initializes the query with the city parameter.
  # 2. Creates a hash mapping possible info arguments to their query values.
  # 3. Iterates through the arguments array, checking if each argument is in the hash.
  #    If it is, appends the specific query to the query string and pushes the value to format_args.
  # 4. If the query string only contains the city query, it means no info arguments were provided,
  #    so the default 'standard' unit is pushed.
  def build_request(argv, city)
    querys = "q=#{city}"

    units = { '--tempC' => 'metric', '-tmpC' => 'metric', '--tempF' => 'imperial', '-tmpF' => 'imperial' }

    argv.each do |arg|
      if units[arg]
        querys << "&units=#{units[arg]}"
        @format_args.push(units[arg])
      end
    end

    @format_args.push('standard') if querys == "q=#{city}"

    querys
  end

  def help
    puts 'Usage: weathercli [CITY] [OPTION] [etc..]
Special case1: weathercli [OPTION] : this option must be --help or -h or --version or -v
Special case2: weathercli : this print the help menu

[etc...] : this means you can put many options has you need example [CITY][OPTION1][OPTION2][OPTION3]..........

Mandatory arguments to long options are mandatory for short options too.

  Format Arguments:

  --tempC  -tmpC  change the format of the temp to Celcius degrees & the velocity metrics format to Km/h
  --tempF  -tmpF  change the format of the temp to Farenheit degrees & the velocity metrics format to miles/hour
  Important : If you not pass this arguments of temp the standard metrics is Kelvin for the temp and Km/h for the velocity

  Info arguments :

  --wind-speed -wS  only output the wind speed
  --temp  -tmp  only output the temp
  --feels-like -fl only output the termic sensation
  --maxtemp -mtmp only output the max temp
  --mintemp -mitmp only output the min temp
  --humidity -hum only output the humidity
  --condition -con only output the weather condition
  --clouds    -cl  only output the clouds %
  --sea-level -sl  only output the sea level

Special arguments:
-h  --help     output this menu
-v  --version  output version information and exit'
  end
end
