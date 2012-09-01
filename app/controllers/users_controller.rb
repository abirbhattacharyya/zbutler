class UsersController < ApplicationController
  def destroy
    reset_session # remove your cookies!
    flash[:notice] = "You have been logged out."
    redirect_to('/')
  end

  def gifts
    friend_uid = params[:id]
    @friend = Friend.find_by_uid(friend_uid)
    @gifts = Array.new
    get_amazon_gifts
    @gifts = @gifts.sort_by{|gift| gift.like_image }
    @gifts.reverse!
    render :update do |page|
#      page.replace_html "gift_suggestions_div", :partial => 'gift_details'
      page.replace_html "gift_suggestions_div", :partial => 'gifts'
    end
  end
  
  def gift_likes
    if request.xhr?
      gift_id = params[:id]
      gift_category = params[:category]
      amazon_data = "amazon_#{gift_category.downcase.strip.pluralize}".classify.constantize.find_by_id(gift_id)
      amazon_data.like = !amazon_data.like
      amazon_data.save(false)
      render :update do |page|
        page.replace_html "like_#{gift_id}_#{gift_category}", amazon_data.like_image
      end
    end
  end


  def get_amazon_data
    @friend = Friend.find(params[:id])

    get_amazon_details


    get_amazon_gifts
    
    if @gifts.empty?
      get_movies(current_user, @friend, true) if @friend.movies.empty?
      get_musics(current_user, @friend, true) if @friend.musics.empty?
      get_books(current_user, @friend, true) if @friend.books.empty?
      @friend.reload
      get_amazon_details
      @friend.reload
      get_amazon_gifts

    end
    render :update do |page|
      if @gifts.empty?
        page.replace_html :spinner , "<h3>We require a bit more info to determine a personalized gift for #{@friend.name} </h3>"
      else
        page.replace_html :spinner , ""
        page.replace_html :gifts_div,:partial => "gift_details"
      end
    end

  end


  def invite_friends
    
  end

  private

  def get_amazon_gifts
    @gifts ||=Array.new
    amazon_books = AmazonBook.find(:all,:conditions => ["friend_id = ?",@friend.id],:group => :name,:include => [:friend])
    amazon_musics = AmazonMusic.find(:all,:conditions => ["friend_id = ?",@friend.id],:group => :name,:include => [:friend])
    amazon_movies = AmazonMovie.find(:all,:conditions => ["friend_id = ?",@friend.id],:group => :name,:include => [:friend])

    @gifts.push(amazon_books).flatten!
    @gifts.push(amazon_musics).flatten!
    @gifts.push(amazon_movies).flatten!
    @gifts = @gifts.sort_by{|gift| gift.like_image }
    @gifts.reverse!
  end


  def get_amazon_details
    max_data_by_category = 5
    book_names = @friend.books.map(&:name)      
    unless book_names.empty?
      amazon_book_data = 0
      book_names.each do |book_name|
        break if amazon_book_data >= max_data_by_category
        amazon_books,resp_code = AmazonApi.get_product_details("books", book_name)
        break if resp_code.to_i == 503
        unless amazon_books.empty?
            amazon_books.each do |amazon_book|
              amz_book = AmazonBook.find_or_initialize_by_friend_id_and_name(@friend.id,amazon_book)
              amz_book.friend_id = @friend.id
              amz_book.save
              amazon_book_data += 1
              break if amazon_book_data >= max_data_by_category
            end
        end
      end
    end

      music_names = @friend.musics.map(&:name)        
      unless music_names.empty?
        amazon_music_data = 0
        music_names.each do |music_name|
          break if amazon_music_data >= max_data_by_category
          amazon_musics,resp_code = AmazonApi.get_product_details("musics", music_name)
          break if resp_code.to_i == 503
          unless amazon_musics.empty?
            amazon_musics.each do |amazon_music|
              amz_music = AmazonMusic.find_or_initialize_by_friend_id_and_name(@friend.id,amazon_music)
              amz_music.friend_id = @friend.id
              amz_music.save
              amazon_music_data += 1
               break if amazon_music_data >= max_data_by_category
            end
          end
        end
      end

      movie_names = @friend.movies.map(&:name)
      
      unless movie_names.empty?
        amazon_movie_data = 0
        movie_names.each do |movie_name|
          break if amazon_movie_data >= max_data_by_category
          amazon_movies,resp_code = AmazonApi.get_product_details("movies", movie_name)
          break if resp_code.to_i == 503
          unless amazon_movies.empty?
            amazon_movies.each do |amazon_movie|
              amz_movie = AmazonMovie.find_or_initialize_by_friend_id_and_name(@friend.id,amazon_movie)
              amz_movie.friend_id = @friend.id
              amz_movie.save
              amazon_movie_data += 1              
               break if amazon_movie_data >= max_data_by_category
            end
          end
        end
      end
  end


  def get_movies(user, friend, is_friend=nil)
        url = "https://graph.facebook.com/#{friend.uid}/movies?access_token=#{user.remember_token}"
        puts "\tMovies, %s" % [friend.uid]
        data = JSON.parse(open(url).read)
        for movie in data["data"]
          new_record = ((!is_friend.nil?) ? user.movies.find_or_initialize_by_friend_id_and_movie_id(friend.id, movie["id"]) : user.movies.find_or_initialize_by_movie_id(movie["id"]))
          new_record.name = movie["name"]
          new_record.category = movie["category"]
          new_record.save
          puts "\t\t%s, %s" % [new_record.movie_id, new_record.name]
        end
  end

  def get_musics(user, friend, is_friend=nil)
        url = "https://graph.facebook.com/#{friend.uid}/music?access_token=#{user.remember_token}"
        puts "\tMusics, %s" % [friend.uid]
        data = JSON.parse(open(url).read)
        for music in data["data"]
          new_record = ((!is_friend.nil?) ? user.musics.find_or_initialize_by_friend_id_and_music_id(friend.id, music["id"]) : user.musics.find_or_initialize_by_music_id(music["id"]))
          new_record.name = music["name"]
          new_record.category = music["category"]
          new_record.save
          puts "\t\t%s, %s" % [new_record.music_id, new_record.name]
        end
  end

  def get_books(user, friend, is_friend=nil)
      url = "https://graph.facebook.com/#{friend.uid}/books?access_token=#{user.remember_token}"
      puts "\tBooks, %s" % [friend.uid]
      data = JSON.parse(open(url).read)
      for book in data["data"]
        new_record = ((!is_friend.nil?) ? user.books.find_or_initialize_by_friend_id_and_book_id(friend.id, book["id"]) : user.books.find_or_initialize_by_book_id(book["id"]))
        new_record.name = book["name"]
        new_record.category = book["category"]
        new_record.save
        puts "\t\t%s, %s" % [new_record.book_id, new_record.name]
      end
  end
  

end
