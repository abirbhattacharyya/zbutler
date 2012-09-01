# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'open-uri'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
require 'base64'
require 'json'
require 'hpricot'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include ApplicationHelper
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  

  # Facebook's base64 algorithm is a special "URL" version of the algorithm.
  def base64_url_decode(str)
    str += '=' * (4 - str.length.modulo(4))
    Base64.decode64(str.tr('-_','+/'))
  end

  # Verifies that the signed_request parameter is from Facebook. An
  # exception is thrown if it is not. A hash with the data from the
  # request is returned.
  def parse_signed_request(params, app_secret_key)
    raise Exception.new("No signed request parameter!") unless params.has_key?("signed_request")
    # signed_request is a . delimited string, first part is the signature
    # base64 encoded, second part is the JSON object base64 encoded
    parts = params['signed_request'].split(".")
    json_str = base64_url_decode(parts[1])
    json_obj = JSON.parse(json_str)
    if json_obj['algorithm'] && json_obj['algorithm'] != 'HMAC-SHA256'
      raise Exception.new("Unsupported signature algorithm - #{json_obj['algorithm']}")
    end
    # This is our calculation of the secret key
    expected = OpenSSL::HMAC.digest('sha256',app_secret_key,parts[1])
    actual = base64_url_decode(parts[0])
    if expected != actual
#      raise Exception.new("Validation of request from Facebook failed!")
        return nil
    end
    # This should contain issued_at at a minimum. If this came from a user
    # that has installed your app, it will contain user_id, oauth_token,
    # expires, app_data, page, profile_id
    json_obj
  end
#  def base64_url_decode str
#    encoded_str = str.gsub('-','+').gsub('_','/')
#    encoded_str += '=' while !(encoded_str.size % 4).zero?
#    Base64.decode64(encoded_str)
#  end

  def decode_data str
    encoded_sig, payload = str.split('.')
    data = ActiveSupport::JSON.decode base64_url_decode(payload)
    return encoded_sig
  end
  
  def fb_app_path
    ((Rails.env.production?) ? "http://apps.facebook.com/zbutler" : "http://apps.facebook.com/price_plunge")
#    "http://apps.facebook.com/fb_like_page"
  end
  
  def oauth_key(provider="foursquare")
    case provider
      when "foursquare"
      ((Rails.env.production?) ? 'AEKYZP0PXP5LYUI4GA1DGPMKFE2NJPC4Q2TYEFS1T5EEGZ4J' : 'CMEUEJBC4CEEFDMYNC2ED10RGDTO1EXLVZNHBW1UHCMMF1RQ')
      when "facebook"
      ((Rails.env.production?) ? '269802526423298' : '147984555267190')
#      '143887789027717'
    end
  end
  
  def oauth_secret(provider="foursquare")
    case provider
      when "foursquare"
      ((Rails.env.production?) ? 'BIHOTHP2PADALAUR4SGY1OPVVMJYRF5E34Y5BE5XVOX1PD3G' : 'ABQEH4KSKS5FYKIYJCOUTQAEJG25BP50Z1D33LSJJNDR1FCY')
      when "facebook"
      ((Rails.env.production?) ? '9c54d3bc1a7a1075732081de85f1a2fc'  : '721e47d9fff31dd5dee44bb37f11b1d2')
#      'ffbba4cee715882e37d9b845d4df622a'
    end
  end
end
