class User < ActiveRecord::Base
  has_many :friends,:include => [:movies,:musics,:books]
  has_many :movies
  has_many :musics
  has_many :books
  
  def uid
    self.fb_uid
  end
end
