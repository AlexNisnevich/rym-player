class Options
  def self.parse(args)
    options = {
      :genre => "",
      :year => "alltime",
      :country => ""
    }

    OptionParser.new do |opts|
      opts.banner = "Usage: ruby ./rym-player.rb [options]"

      opts.on("-g", "--genre [GENRE]", "Limit search to the given genre") do |genre|
        options[:genre] = genre
      end

      opts.on("-y", "--year [YEAR]", "Limit search to the given year") do |year|
        options[:year] = year
      end

      opts.on("-c", "--country [COUNTRY]", "Limit search to the given country") do |country|
        options[:country] = self.parse_country(country)
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.on_tail("-v", "--version", "Show version") do
        puts "rym-player #{VERSION}"
        exit
      end
    end.parse!(args)

    p options
  end

  # allowing some common country abbreviations
  def self.parse_country(country)
    country.downcase!

    case country
    when "russia"
      "russian federation"
    when "uk"
      "united kingdom"
    when "usa"
      "united states"
    else
      country
    end
  end
end
