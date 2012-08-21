require "oauth"
require "json"

# Describes the overall status of an API call.
module MiiApiCallStatus
	# The API call succeeded - the associated result information can be found
	# in the data property of the response object.
	SUCCESS = 0
	# The API call failed. You can get more information about the nature of
	# the failure by examining the error_code property.
	FAILURE = 1
end

# Details a specific problem that occurred when accessing the API.
module MiiApiErrorCode
	# The API call succeeded.
	SUCCESS = 0
	# The user has revoked access to your application. The user would
	# have to repeat the OAuth authorisation process before access would be
	# restored to your application.
	ACCESS_REVOKED = 100
	# The user's miiCard subscription has elapsed. Only users with a current
	# subscription can share their data with other applications and websites.	
    USER_SUBSCRIPTION_LAPSED = 200
	# A general exception occurred during processing - details may be available
	# in the error_message property of the response object depending upon the
	# nature of the exception.
    EXCEPTION = 10000
end

# Base class for most verifiable identity data.
class Claim
	attr_accessor :verified
	
	def initialize(verified)
		@verified = verified
	end
end

class Identity < Claim
	attr_accessor :source, :user_id, :profile_url
	
	def initialize(verified, source, user_id, profile_url)
		super(verified)
		
		@source = source
		@user_id = user_id
		@profile_url = profile_url
	end
	
	def self.from_hash(hash)
		return Identity.new(
			hash["Verified"], 
			hash["Source"], 
			hash["UserId"], 
			hash["ProfileUrl"]
		)
	end
end

class EmailAddress < Claim
	attr_accessor :display_name, :address, :is_primary
	
	def initialize(verified, display_name, address, is_primary)
		super(verified)
		
		@display_name = display_name
		@address = address
		@is_primary = is_primary
	end
	
	def self.from_hash(hash)
		return EmailAddress.new(
			hash["Verified"], 
			hash["DisplayName"], 
			hash["Address"], 
			hash["IsPrimary"]
		)
	end
end

class PhoneNumber < Claim
	attr_accessor :display_name, :country_code, :national_number, :is_mobile, :is_primary
	
	def initialize(verified, display_name, country_code, national_number, is_mobile, is_primary)
		super(verified)
		
		@display_name = display_name
		@country_code = country_code
		@national_number = national_number
		@is_mobile = is_mobile
		@is_primary = is_primary
	end
	
	def self.from_hash(hash)
		return PhoneNumber.new(
			hash["Verified"], 
			hash["DisplayName"], 
			hash["CountryCode"], 
			hash["NationalNumber"], 
			hash["IsMobile"], 
			hash["IsPrimary"]
		)
	end
end

class PostalAddress < Claim
	attr_accessor :house, :line1, :line2, :city, :region, :code, :country, :is_primary
	
	def initialize(verified, house, line1, line2, city, region, code, country, is_primary)
		super(verified)
		
		@house = house
		@line1 = line1
		@line2 = line2
		@city = city
		@region = region
		@code = code
		@country = country
		@is_primary = is_primary
	end
	
	def self.from_hash(hash)
		return PostalAddress.new(
			hash["Verified"], 
			hash["House"], 
			hash["Line1"], 
			hash["Line2"], 
			hash["City"], 
			hash["Region"], 
			hash["Code"], 
			hash["Country"], 
			hash["IsPrimary"]
		)
	end
end

class WebProperty < Claim
	attr_accessor :display_name, :identifier, :type
	
	def initialize(verified, display_name, identifier, type)
		super(verified)
		
		@display_name = display_name
		@identifier = identifier
		@type = type
	end
	
	def self.from_hash(hash)
		return WebProperty.new(
			hash["Verified"],
			hash["DisplayName"], 
			hash["Identifier"], 
			hash["Type"]
		)
	end
end

class MiiUserProfile
	attr_accessor :username, :salutation, :first_name, :middle_name, :last_name
	attr_accessor :previous_first_name, :previous_middle_name, :previous_last_name
	attr_accessor :last_verified, :profile_url, :profile_short_url, :card_image_url, :email_addresses, :identities, :postal_addresses
	attr_accessor :phone_numbers, :web_properties, :identity_assured, :has_public_profile
	attr_accessor :public_profile
	
	def initialize(
		username,
		salutation,
        first_name,
        middle_name,
        last_name,
        previous_first_name,
        previous_middle_name,
        previous_last_name,
        last_verified,
        profile_url,
        profile_short_url,
        card_image_url,
        email_addresses,
        identities,
        phone_numbers,
        postal_addresses,
        web_properties,
        identity_assured,
        has_public_profile,
        public_profile
		)
		
		@username= username
		@salutation = salutation
        @first_name = first_name
        @middle_name = middle_name
        @last_name = last_name
        @previous_first_name = previous_first_name
        @previous_middle_name = previous_middle_name
        @previous_last_name = previous_last_name
        @last_verified = last_verified
        @profile_url = profile_url
        @profile_short_url = profile_short_url
        @card_image_url = card_image_url
        @email_addresses = email_addresses
        @identities = identities
        @phone_numbers = phone_numbers
        @postal_addresses = postal_addresses
        @web_properties = web_properties
        @identity_assured = identity_assured
        @has_public_profile = has_public_profile
        @public_profile = public_profile
	end
	
	def self.from_hash(hash)
		emails = hash["EmailAddresses"]
		emails_parsed = nil
		unless (emails.nil? || emails.empty?)
			emails_parsed = emails.map{|item| EmailAddress::from_hash(item)}
		end
		
		identities = hash["Identities"]
		identities_parsed = nil
		unless (identities.nil? || identities.empty?)
			identities_parsed = identities.map{|item| Identity::from_hash(item)}
		end
		
		phone_numbers = hash["PhoneNumbers"]
		phone_numbers_parsed = nil
		unless (phone_numbers.nil? || phone_numbers.empty?)
			phone_numbers_parsed = phone_numbers.map{|item| PhoneNumber::from_hash(item)}
		end		
		
		postal_addresses = hash["PostalAddresses"]
		postal_addresses_parsed = nil
		unless (postal_addresses.nil? || postal_addresses.empty?)
			postal_addresses_parsed = postal_addresses.map{|item| PostalAddress::from_hash(item)}
		end
		
		web_properties = hash["WebProperties"]
		web_properties_parsed = nil
		unless (web_properties.nil? || web_properties.empty?)
			web_properties_parsed = web_properties.map{|item| WebProperty::from_hash(item)}
		end
		
		public_profile = hash["PublicProfile"]
		public_profile_parsed = nil
		unless public_profile.nil?
			public_profile_parsed = MiiUserProfile::from_hash(public_profile)
		end
		
		return MiiUserProfile.new(
			hash['Username'],
			hash['Salutation'],
			hash['FirstName'],
			hash['MiddleName'],
			hash['LastName'],
			hash['PreviousFirstName'],
			hash['PreviousMiddleName'],
			hash['PreviousLastName'],
			hash['LastVerified'],
			hash['ProfileUrl'],
			hash['ProfileShortUrl'],
			hash['CardImageUrl'],
			emails_parsed,
			identities_parsed,
			phone_numbers_parsed,
			postal_addresses_parsed,
			web_properties_parsed,
			hash['IdentityAssured'],
			hash['HasPublicProfile'],
			public_profile_parsed
			)			
	end
end

class MiiApiResponse
	attr_accessor :status, :error_code, :error_message, :data
	
	def initialize(status, error_code, error_message, data)
		@status = status
		@error_code = error_code
		@error_message = error_message
		@data = data
	end
	
	def self.from_hash(hash, data_processor)
		payload_json = hash["Data"]
		
		if payload_json && !data_processor.nil?
			payload = data_processor.call(payload_json)
		elsif !(payload_json.nil?)
			payload = payload_json
		else
			payload = nil
		end
			
		return MiiApiResponse.new(
			hash["Status"], 
			hash["ErrorCode"],
			hash["ErrorMessage"],
			payload
		)
	end
end

class MiiCardOAuthServiceBase
	attr_accessor :consumer_key, :consumer_secret, :access_token, :access_token_secret
	
	def initialize(consumer_key, consumer_secret, access_token, access_token_secret)
		@consumer_key = consumer_key
		@consumer_secret = consumer_secret
		@access_token = access_token
		@access_token_secret = access_token_secret
	end
end

class MiiCardOAuthClaimsService < MiiCardOAuthServiceBase
	def initialize(consumer_key, consumer_secret, access_token, access_token_secret)
		super(consumer_key, consumer_secret, access_token, access_token_secret)
	end
	
	def get_claims
		return make_request(MiiCardServiceUrls.get_method_url('GetClaims'), nil, MiiUserProfile.method(:from_hash), true)
	end
	
	def is_social_account_assured(social_account_id, social_account_type)
		params = Hash["socialAccountId", social_account_id, "socialAccountType", social_account_type]
		
		return make_request(MiiCardServiceUrls.get_method_url('IsSocialAccountAssured'), params, nil, true)
	end
	
	def is_user_assured
		return make_request(MiiCardServiceUrls.get_method_url('IsUserAssured'), nil, nil, true)
	end
	
	def assurance_image(type)
		params = Hash["type", type]
		
		return make_request(MiiCardServiceUrls.get_method_url('AssuranceImage'), params, nil, false)
	end
	
	private
	def make_request(url, post_data, payload_processor, wrapped_response)
		consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, {:site => MiiCardServiceUrls::STS_SITE, :request_token_path => MiiCardServiceUrls::OAUTH_ENDPOINT, :access_token_path => MiiCardServiceUrls::OAUTH_ENDPOINT, :authorize_path => MiiCardServiceUrls::OAUTH_ENDPOINT })
		access_token = OAuth::AccessToken.new(consumer, @access_token, @access_token_secret)
				
		response = access_token.post(url, post_data.to_json(), { 'Content-Type' => 'application/json' })
		
		if wrapped_response
			return MiiApiResponse::from_hash(JSON.parse(response.body), payload_processor)
		elsif !payload_processor.nil?
			return payload_processor.call(response.body)
		else
			return response.body
		end
	end
end

class MiiCardServiceUrls
	OAUTH_ENDPOINT = "https://sts.miicard.com/auth/OAuth.ashx"
	STS_SITE = "https://sts.miicard.com"
    CLAIMS_SVC = "https://sts.miicard.com/api/v1/Claims.svc/json"
	
	def self.get_method_url(method_name)
		return MiiCardServiceUrls::CLAIMS_SVC + "/" + method_name
	end
end

