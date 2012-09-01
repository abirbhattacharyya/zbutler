require 'amazon/aws/search'
require 'cgi'
include Amazon::AWS
include Amazon::AWS::Search
module AmazonApi


  CATEGORY = {
    "books" => "Books",
    "musics" => "Music",
    "movies" => "DVD"
  }


  def self.get_product_details(category,keyword)
      keyword =self.remove_special_charcters(keyword)
      products = Array.new      
      respone_code = 200
      is = ItemSearch.new(CATEGORY[category.downcase], {'Title' => keyword} )
      is.response_group = ResponseGroup.new( 'Large' )

      req = Request.new
      req.locale = 'us'
      begin
        resp = req.search( is )        
        items = resp.item_search_response[0].items[0].item
        items = items
      rescue => e
        puts "#{resp.inspect}"
        if e.message.match("503")
          puts "Error from Amazon API 503: #{e.message}"
          respone_code = 503
        else
           puts "Error from Amazon API other: #{e.message}"
        end

        items = []
      end
      unless items.empty?
        items.each_with_index do |item,item_index|
          puts "#{item_index + 1} from #{items.size}"
          product_detail = Hash.new
          begin
            product_url = item.detail_page_url.to_s
            name = item.item_attributes.title.to_s
            list_price =item.item_attributes.list_price.formatted_price.to_s.gsub("$","").to_f
            price = item.offers.first.offer.offer_listing.price.formatted_price.to_s.gsub("$","").to_f
            image_url = item.medium_image.url.to_s
          rescue => e
#            puts "-"*20
#            puts product_url
#            puts  e.message
#            puts "-"*20
            next
          end
          description = begin CGI.unescapeHTML(item.editorial_reviews.editorial_review.first.content.to_s)  rescue nil end
          keyword_regex = Regexp.new("\\b" + keyword.downcase + "\\b")
          if name.downcase.match(keyword_regex)
            product_detail["product_url"] = product_url
            product_detail["name"] = name
            product_detail["list_price"] = list_price
            product_detail["price"] = price
            product_detail["image_url"] = image_url
            product_detail["description"] = description

            products.push(product_detail)
            break unless products.empty?
          end
        end
      end
      return products,respone_code
  end




  def self.remove_special_charcters(keyword)
    return nil if keyword.nil?
    keyword = keyword.gsub(/[^A-Za-z0-9 ]/,"")
    return keyword.strip
  end

end