class Book < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend
end
