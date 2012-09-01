class Friend < ActiveRecord::Base
  belongs_to :user
  has_many :movies
  has_many :musics
  has_many :books
  
  has_many :amazon_movies
  has_many :amazon_musics
  has_many :amazon_books
  
  def image_url
    (self.pic_url || ((self.sex.eql? "male") ? "/images/fb_default_male.png" : "/images/fb_default_female.png"))
  end
  
  def birthday_view
    (self.birthdate ? self.birthdate.strftime("%B, %d") : "-")
  end
  
  def add_more_user_info(data)
    self.name = (data/"name").innerHTML
    self.user_name = (data/"username").innerHTML
    self.first_name = (data/"first_name").innerHTML
    self.last_name = (data/"last_name").innerHTML
    self.sex = (data/"sex").innerHTML
    self.email = (data/"email").innerHTML
    self.locale = (data/"locale").innerHTML
    self.pic_url = (data/"pic").innerHTML
    self.verified = (data/"verified").innerHTML.to_i
    birthdate_data = (data/"birthday").innerHTML
    unless birthdate_data.blank?
      birthdate_data = ((birthdate_data.include?(",")) ? birthdate_data.to_date : "#{birthdate_data}, 1900".to_date)
      self.birthdate = birthdate_data
    end
  end
  
  def update_user_info(hash)
      self.update_attributes( 
        :uid => hash["id"],
        :name => hash["name"],
#        :email => hash["email"],
        :user_name => hash["username"],
        :first_name => hash["first_name"],
        :last_name => hash["last_name"],
        :sex => hash["gender"],
        :locale => hash["locale"]
      )
  end

  def has_gifts?
    status = false
    if !self.amazon_books.empty?
      status = true
    elsif !self.amazon_movies.empty?
        status = true
    elsif !self.amazon_musics.empty?
        status = true
    end
    return status
  end
end
