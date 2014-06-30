
class Album
  attr_accessor :num, :title, :artists, :genres, :rating, :url, :year

  def all_artists
    @artists.join(", ")
  end

  def primary_artist
    @artists.first
  end

  def skip?
    File.readlines(SKIP_FILE).grep(Regexp.new @url).any?
  end

  def skip_in_future
    open(SKIP_FILE, 'a') { |f|
      f.puts @url
    }
    puts "Added #{@url} to skip list"
  end

  def to_s
    JSON.pretty_generate({
      '#' => @num,
      :album => @title,
      :artists => all_artists,
      :genres => @genres,
      :rating => @rating,
      :url => @url,
      :year => @year
    })
  end

  def find_youtube_video
    opts = Trollop::options do
      opt :q, 'Search term', :type => String
      opt :maxResults, 'Max results', :type => :int, :default => 25
    end

    client = Google::APIClient.new(:key => DEVELOPER_KEY,
                                   :authorization => nil,
                                   :application_name => 'rym-listen',
                                   :application_version => VERSION)
    youtube = client.discovered_api("youtube", "v3")

    opts[:part] = 'id,snippet'
    opts[:q] = "#{primary_artist} #{@title} full album"
    search_response = client.execute!(
      :api_method => youtube.search.list,
      :parameters => opts
    )

    videos = search_response.data.items.select {|res| res.id.kind == 'youtube#video'}

    video = videos.find {|res|
              title = res.snippet.title.downcase
              title.include?(primary_artist.downcase) &&
                  title.include?(@title.downcase) &&
                  title.include?('full')
            }

    video ||= videos.find {|res|
                title = res.snippet.title.downcase
                title.include?(primary_artist.downcase) &&
                    title.include?(@title.downcase) &&
                    title.include?('album')
              }

    video ||= videos.first

    video
  end
end
