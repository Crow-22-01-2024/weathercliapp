# WeatherCLI

!WeatherCLI

WeatherCLI is a command-line application that fetches and displays weather information for a specified city using the OpenWeather API.

## Table of Content

- Prerequisites
- Installation
- Usage

## Prerequisites

- Ruby (version 2.5 or higher)
- Bundler gem
- Rake gem
- OpenWeather API key

## Installation

1. Clone the repository:

   ```sh
   git clone https://github.com/Crow-22-01-2024/weathercliapp.git
   cd weathercliapp
   ```

2. Install the required gems:
   The required gems is in the Gemfile you can install via :

   ```sh
    bundle install
   ```

   `or`

   ```sh
   rake install_gems
   ```

3. Create an account in `https://openweathermap.org/api` and sign in

4. Copy your api key in `https://home.openweathermap.org/api_keys`

5. Create a `.env` file in the root directory and add your OpenWeather API key:
   ```sh
   echo "OPENWEATHER_API_KEY=your_api_key_here" > .env
   ```

## Usage

To run the application, use the following command:

```sh
cd bin && chmod +x weathercli && ./weathercli
```
