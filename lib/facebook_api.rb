module FacebookApi



    def self.get_interest_data(type,profile_id,access_token)
     begin
      url = "https://graph.facebook.com/#{profile_id}/#{type}?access_token=#{access_token}"
      puts "url: #{url}"
      data = JSON.parse(open(url).read)
      return data
    rescue
      return nil
    end
    end

end