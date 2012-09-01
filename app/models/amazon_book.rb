class AmazonBook < ActiveRecord::Base
  belongs_to :friend
  def category() "Book" end
  
  def like_image
#    ((self.like == false) ? "/images/like.jpg" :  "/images/unlike.jpg")
    ((self.like == false) ? "Like" :  "Unlike")
  end
end
