class HomeController < ApplicationController
  def index
    if params[:signed_request]
      begin
        signed_request = parse_signed_request(params, oauth_secret("facebook"))
        if signed_request["user_id"]
          session[:signed_request] = params[:signed_request]
          session[:user_id] = signed_request["user_id"]
        
          get_friends(current_user, current_user.fb_uid)# if current_user.friends.empty?
          current_user.reload
          @friends = current_user.friends
          get_details
          @friends.delete_if{|friend| friend.uid == current_user.fb_uid}
          #render :template => "/home/friends_list"
        else
          redirect_to :action => "callback"
        end
      rescue => e
#        render :text => e.message.inspect and return false
        redirect_to :action => "callback" and return
      end
    else
      redirect_to fb_app_path
    end
  end

  def friends_list    
   # begin
      if session[:user_id]
     #   get_friends(current_user, current_user.fb_uid)# if current_user.friends.empty?
        current_user.reload
        @friends = Friend.find(:all,:conditions => ["user_id = ?",current_user.id])#current_user.friends

        #get_details
        @friends.delete_if{|friend| friend.uid == current_user.fb_uid}

        @friends.shuffle!
        friend = @friends.find{ |f| f.has_gifts?}
        @friends.delete(friend)
        @friends= friend.to_a + @friends

        #render :template => "/home/friends_list"
      else
        redirect_to :action => "callback"
      end
#    rescue => e
#      redirect_to :action => "callback" and return
#    end
  end
  
  def callback
      if params[:code]
        url = "https://graph.facebook.com/oauth/access_token?client_id=#{oauth_key("facebook")}&redirect_uri=#{callback_url("facebook")}&client_secret=#{oauth_secret("facebook")}&code=#{params[:code]}"
        data = open(url).read
        redirect_to :action => "failure" and return if data.nil? or data.blank?
        token = data.gsub("access_token=", "")
        url = "https://graph.facebook.com/me?access_token=#{token}"
        data = JSON.parse(open(url).read)
        user = User.find_or_initialize_by_fb_uid(data["id"])
        user.login = data["name"]
        user.remember_token = token
        user.save
        redirect_to("/")
      elsif params[:error]
        redirect_to :action => "failure"
      else
        @redirect_url = "https://www.facebook.com/dialog/oauth?client_id=#{oauth_key("facebook")}&redirect_uri=#{callback_url("facebook")}&scope=publish_stream,offline_access,email,friends_activities,user_activities,friends_likes,friends_interests,user_birthday,friends_birthday"
        render :layout => false
      end
  end
  
  def failure
    redirect_to :action => "callback"
  end
  
  private
  def get_details
#    if(Rails.env.production?)
    if(Rails.env.development?)
      spawn do
        is_new_user = (current_user.updated_at == current_user.created_at)
        if(is_new_user or !(current_user.updated_at.to_date.eql? Date.today))
          begin
#          get_movies(current_user, current_user) if current_user.movies.empty?
#          get_musics(current_user, current_user) if current_user.musics.empty?
#          get_books(current_user, current_user) if current_user.books.empty?
          for friend in @friends
            puts "%s, %s" % [friend.uid, friend.name]
            get_movies(current_user, friend, true) if friend.movies.empty?
            get_musics(current_user, friend, true) if friend.musics.empty?
            get_books(current_user, friend, true) if friend.books.empty?
          end
          rescue => e
            puts "-"*50
            puts e.message
            puts "-"*50
            break
          end
        end
        if(is_new_user or ((Time.now.utc - current_user.updated_at.utc) > 1.hours))
          current_user.update_attributes(:updated_at => Time.now.utc)
          puts "-"*50
          puts "Getting Amazon Data..."
          get_amazon_data(@friends)
          puts "-"*50
          puts "Task Completed"
          puts "-"*50
        end
      end
#    else
#      get_interests(current_user, current_user.fb_uid)
#      return
    end
  end

  def get_interests(user, uid, is_friend=nil)
        url = "https://graph.facebook.com/#{uid}/interests?access_token=#{user.remember_token}"
        puts "\t%s" % [url]
        data = JSON.parse(open(url).read)
        render :text => data.inspect and return false
  end
  
  def get_friends(user, uid)
        if user.friends.empty? or user.friends.find(:first, :conditions => "first_name IS NULL")
          url = "https://api.facebook.com/method/fql.query?query=%s&access_token=%s"%[CGI.escape("SELECT uid, name, username, first_name, last_name, sex, email, locale, birthday, pic, verified FROM user WHERE uid = #{uid} OR uid IN (SELECT uid2 FROM friend WHERE uid1 = #{uid})"), user.remember_token.to_s]
          puts "Friends, %s" % [uid]
          data = Hpricot::XML(open(url).read)
          (data/:user).each do |user_info|
            new_record = user.friends.find_or_initialize_by_uid((user_info/"uid").innerHTML)
            new_record.add_more_user_info(user_info)
            new_record.save
            if new_record.new_record?
              puts "\t%s, %s" % [new_record.uid, new_record.name]
            end
          end
        end
        return
        
#        url = "https://graph.facebook.com/#{uid}/friends?access_token=#{user.remember_token}"
#        data = JSON.parse(open(url).read)
#        for friend in data["data"]
#          new_record = ((!is_friend.nil?) ? user.friends.find_or_initialize_by_friend_id_and_uid(uid, friend["id"]) : user.friends.find_or_initialize_by_uid(friend["id"]))
#          new_record.name = friend["name"]
#          new_record.save
##          hash = JSON.parse(open("https://graph.facebook.com/#{new_record.uid}").read)
##          new_record.update_user_info(hash)
#          puts "\t%s, %s" % [new_record.uid, new_record.name]
#        end
  end
  
  def get_movies(user, friend, is_friend=nil)
        url = "https://graph.facebook.com/#{friend.uid}/movies?access_token=#{user.remember_token}"
        puts "\tMovies, %s" % [friend.uid]
#        begin
        data = JSON.parse(open(url).read)
        for movie in data["data"]
          new_record = ((!is_friend.nil?) ? user.movies.find_or_initialize_by_friend_id_and_movie_id(friend.id, movie["id"]) : user.movies.find_or_initialize_by_movie_id(movie["id"]))
          new_record.name = movie["name"]
          new_record.category = movie["category"]
          new_record.save
          puts "\t\t%s, %s" % [new_record.movie_id, new_record.name]
        end
#        rescue => e
#          puts "-"*50
#          puts e.message
#          puts "-"*50
#        end
  end
  
  def get_musics(user, friend, is_friend=nil)
        url = "https://graph.facebook.com/#{friend.uid}/music?access_token=#{user.remember_token}"
        puts "\tMusics, %s" % [friend.uid]
#        begin
        data = JSON.parse(open(url).read)
        for music in data["data"]
          new_record = ((!is_friend.nil?) ? user.musics.find_or_initialize_by_friend_id_and_music_id(friend.id, music["id"]) : user.musics.find_or_initialize_by_music_id(music["id"]))
          new_record.name = music["name"]
          new_record.category = music["category"]
          new_record.save
          puts "\t\t%s, %s" % [new_record.music_id, new_record.name]
        end
#        rescue => e
#          puts "-"*50
#          puts e.message
#          puts "-"*50
#        end
  end
  
  def get_books(user, friend, is_friend=nil)
      url = "https://graph.facebook.com/#{friend.uid}/books?access_token=#{user.remember_token}"
      puts "\tBooks, %s" % [friend.uid]
#      begin
      data = JSON.parse(open(url).read)
      for book in data["data"]
        new_record = ((!is_friend.nil?) ? user.books.find_or_initialize_by_friend_id_and_book_id(friend.id, book["id"]) : user.books.find_or_initialize_by_book_id(book["id"]))
        new_record.name = book["name"]
        new_record.category = book["category"]
        new_record.save
        puts "\t\t%s, %s" % [new_record.book_id, new_record.name]
      end
#      rescue => e
#        puts "-"*50
#        puts e.message
#        puts "-"*50
#      end
  end
  
  def get_amazon_data(friends)
    puts "Geting Amazon Data for #{friends.size} friends"
    friend_ids = friends.map(&:id)
    friend_amazon_ids = AmazonBook.all(:conditions => ["friend_id IN (?)", friend_ids]).map(&:friend_id).uniq
    get_amazon_books(friend_ids-friend_amazon_ids)
    friend_amazon_ids = AmazonMusic.all(:conditions => ["friend_id IN (?)", friend_ids]).map(&:friend_id).uniq
    get_amazon_musics(friend_ids-friend_amazon_ids)
    friend_amazon_ids = AmazonMovie.all(:conditions => ["friend_id IN (?)", friend_ids]).map(&:friend_id).uniq
    get_amazon_movies(friend_ids-friend_amazon_ids)
  end
  
  def get_amazon_books(friend_ids)
    books = Book.all(:include => [:friend], :conditions => ["friend_id IN (?)", friend_ids])
    taken_book_names = Array.new
    for book in books
      next if taken_book_names.include?(book.name)
      taken_book_names.push(book.name)
      puts "%s, %s"%[book.friend.name, book.name]
      amazon_books,resp_code = AmazonApi.get_product_details("books", book.name)
      break if resp_code.to_i == 503
      puts "%s books found"%[amazon_books.size]
      amazon_books.each_with_index do |amazon_book, index|
        aws = AmazonBook.find_or_initialize_by_friend_id_and_name(book.friend.id, amazon_book["name"])
        aws.attributes = amazon_book
        unless aws.save
          puts "%s"%[aws.errors.full_messages.inspect]
        end
      end
    end
  end
  
  def get_amazon_musics(friend_ids)
    puts "#{friend_ids.inspect}"
    musics = Music.all(:include => [:friend], :conditions => ["friend_id IN (?)", friend_ids])
    taken_music_names = Array.new
    for music in musics
      next if taken_music_names.include?(music.name)
      taken_music_names.push(music.name)
      puts "%s, %s"%[music.friend.name, music.name]
      amazon_musics,resp_code = AmazonApi.get_product_details("musics", music.name)

      break if resp_code.to_i == 503
      puts "%s musics found"%[amazon_musics.size]
      amazon_musics.each_with_index do |amazon_music, index|
        aws = AmazonMusic.find_or_initialize_by_friend_id_and_name(music.friend.id, amazon_music["name"])
        aws.attributes = amazon_music
        unless aws.save
          puts "%s"%[aws.errors.full_messages.inspect]
        end
      end
    end
  end
  
  def get_amazon_movies(friend_ids)
    movies = Movie.all(:include => [:friend], :conditions => ["friend_id IN (?)", friend_ids])
    taken_movie_names = Array.new
    for movie in movies
      next if taken_movie_names.include?(movie.name)
      taken_movie_names.push(movie.name)
      puts "%s, %s"%[movie.friend.name, movie.name]
      amazon_movies,resp_code = AmazonApi.get_product_details("movies", movie.name)
      break if resp_code.to_i == 503
      puts "%s movies found"%[amazon_movies.size]
      amazon_movies.each_with_index do |amazon_movie, index|
#        puts "-"*50
#        puts "Movie #%d, %s"%[(index+1), amazon_movie.keys.inspect]
        aws = AmazonMovie.find_or_initialize_by_friend_id_and_name(movie.friend.id, amazon_movie["name"])
        aws.attributes = amazon_movie
        unless aws.save
          puts "%s"%[aws.errors.full_messages.inspect]
        end
      end
    end
  end
end
