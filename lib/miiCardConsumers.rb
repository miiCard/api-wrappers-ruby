require "oauth"
require "json"
require "digest/sha1"
require "net/http"
require "openssl/x509"

class MiiCardServiceUrls
	OAUTH_ENDPOINT = "https://sts.miicard.com/auth/OAuth.ashx"
	STS_SITE = "https://sts.miicard.com"
	CLAIMS_SVC = "https://sts.miicard.com/api/v1/Claims.svc/json"
	FINANCIAL_SVC = "https://sts.miicard.com/api/v1/Financial.svc/json"
	DIRECTORY_SVC = "https://sts.miicard.com/api/v1/Members"
	
	# Deprecated - prefer the API-specific methods get_claims_method_url
	# and get_financial_method_url
	def self.get_method_url(method_name)
		return MiiCardServiceUrls::CLAIMS_SVC + "/" + method_name
	end

	def self.get_claims_method_url(method_name)
		return MiiCardServiceUrls::CLAIMS_SVC + "/" + method_name
	end

	def self.get_financial_method_url(method_name)
		return MiiCardServiceUrls::FINANCIAL_SVC + "/" + method_name
	end

	def self.get_directory_service_query_url(criterion, value, hashed = false)
		to_return = DIRECTORY_SVC + "?" + criterion + "=" + value

		if (hashed)
			to_return = to_return + "&hashed=true"
		end

		return to_return
	end
end

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
	# An unrecognised search criterion was supplied to the Directory API
	UNKNOWN_SEARCH_CRITERION = 10
	# No miiCard members matched the Directory API search criteria
	NO_MATCHES = 11
	# The user has revoked access to your application. The user would
	# have to repeat the OAuth authorisation process before access would be
	# restored to your application.
	ACCESS_REVOKED = 100
	# The user's miiCard subscription has elapsed. Only users with a current
	# subscription can share their data with other applications and websites.	
	USER_SUBSCRIPTION_LAPSED = 200
	# Signifies that your account has not been enabled for transactional support.
	TRANSACTIONAL_SUPPORT_DISABLED = 1000
	# Signifies that your account has not been enabled for Financial API support.
	FINANCIAL_DATA_SUPPPORT_DISABLED = 1001
	# Signifies that your account's support status is development-only. This is the
	# case when your application hasn't yet been made live in the miiCard system, for example
	# while we process your billing details and perform final checks.
	DEVELOPMENT_TRANSACTIONAL_SUPPORT_ONLY = 1010
	# Signifies that the snapshot ID supplied to a snapshot-based API method was either invalid
	# or corresponded to a user for which authorisation tokens didn't match.
	INVALID_SNAPSHOT_ID = 1020
	# Signifies that your application has been suspended and no API access can take place
	# until miiCard releases the suspension on your application.
	BLACKLISTED = 2000
	# Signifies that your application has been disabled, either by your request or by miiCard. 
	# miiCard members will be unable to go through the OAuth process for your application, 
	# though you will still be able to access the API.
	PRODUCT_DISABLED = 2010
	# Signifies that your application has been deleted. miiCard members will be unable to go 
	# through the OAuth process for your application, nor will you be able to access identity 
	# details through the API.
	PRODUCT_DELETED = 2020
	# A general exception occurred during processing - details may be available
	# in the error_message property of the response object depending upon the
	# nature of the exception.
	EXCEPTION = 10000
end

# Describes the overall status of an API call.
module WebPropertyType
	# Indicates that the WebProperty relates to a domain name.
	DOMAIN = 0
	# Indicates that the WebProperty relates to a website.
	WEBSITE = 1
end

module QualificationType
	# Indicates that the Qualification relates to an academic award
	ACADEMIC = 0
	# Indicates that the Qualification relates to a professional certification
	PROFESSIONAL = 1
end

module AuthenticationTokenType
	# Specifies that no second factor was employed
	NONE = 0
	# Specifies that a soft token was employed, such as an SMS sent to
	# a registered mobile device or software OATH provider
	SOFT = 1
	# Specifies that a hard token was employed, such as a YubiKey
	HARD = 2
end

module RefreshState
	# Indicates that a request to refresh financial data is in an incomplete, unknown
	# state - probably indicating an error
	UNKNOWN = 0
	# Indicates that the requested financial data refresh has completed and the most
	# recent available financial data can now be requested
	DATA_AVAILABLE = 1
	# Indicates that a requested financial data refresh is still in progress
	IN_PROGRESS = 2
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

class Qualification
	attr_accessor :type, :title, :data_provider, :data_provider_url

	def initialize(type, title, data_provider, data_provider_url)
		@type = type
		@title = title
		@data_provider = data_provider
		@data_provider_url = data_provider_url
	end

	def self.from_hash(hash)
		return Qualification.new(
			hash["Type"],
			hash["Title"],
			hash["DataProvider"],
			hash["DataProviderUrl"]
		)
	end
end

class GeographicLocation
	attr_accessor :location_provider, :latitude, :longitude, :lat_long_accuracy_metres
	attr_accessor :approximate_address

	def initialize(location_provider, latitude, longitude, lat_long_accuracy_metres, approximate_address)
		@location_provider = location_provider
		@latitude = latitude
		@longitude = longitude
		@lat_long_accuracy_metres = lat_long_accuracy_metres
		@approximate_address = approximate_address
	end

	def self.from_hash(hash)	
		postal_address = hash["ApproximateAddress"]
		postal_address_parsed = nil
		unless (postal_address.nil?)
			postal_address_parsed = PostalAddress::from_hash(postal_address)
		end

		return GeographicLocation.new(
			hash["LocationProvider"],
			hash["Latitude"],
			hash["Longitude"],
			hash["LatLongAccuracyMetres"],
			postal_address_parsed
		)
	end
end

class AuthenticationDetails
	attr_accessor :authentication_time_utc, :second_factor_token_type, :second_factor_provider, :locations

	def initialize(authentication_time_utc, second_factor_token_type, second_factor_provider, locations)
		@authentication_time_utc = authentication_time_utc
		@second_factor_token_type = second_factor_token_type
		@second_factor_provider = second_factor_provider
		@locations = locations
	end

	def self.from_hash(hash)
		locations = hash["Locations"]
		locations_parsed = nil
		unless (locations.nil? || locations.empty?)
			locations_parsed = locations.map{|item| GeographicLocation::from_hash(item)}
		end

		return AuthenticationDetails.new(
			(Util::parse_dot_net_json_datetime(hash['AuthenticationTimeUtc']) rescue nil),
			hash['SecondFactorTokenType'],
			hash['SecondFactorProvider'],
			locations_parsed
		)
	end
end

class FinancialRefreshStatus
	attr_accessor :state

	def initialize(state)
		@state = state
	end

	def self.from_hash(hash)
		@state = hash['State']
	end
end

class FinancialTransaction
	attr_accessor :date, :amount_credited, :amount_debited, :description, :id

	def initialize(date, amount_credited, amount_debited, description, id)
		@date = date
		@amount_credited = amount_credited
		@amount_debited = amount_debited
		@description = description
		@id = id
	end

	def self.from_hash(hash)
		return FinancialTransaction.new(
			(Util::parse_dot_net_json_datetime(hash['Date']) rescue nil),
			hash['AmountCredited'],
			hash['AmountDebited'],
			hash['Description'],
			hash['ID']
		)
	end
end

class FinancialAccount
	attr_accessor :account_name, :holder, :sort_code, :account_number, :type, :from_date, :last_updated_utc
	attr_accessor :closing_balance, :debits_sum, :debits_count, :credits_sum, :credits_count, :currency_iso
	attr_accessor :transactions

	def initialize(account_name, holder, sort_code, account_number, type, from_date, last_updated_utc, closing_balance, debits_sum, debits_count, credits_sum, credits_count, currency_iso, transactions)
		@account_name = account_name
		@holder = holder
		@sort_code = sort_code
		@account_number = account_number
		@type = type
		@from_date = from_date
		@last_updated_utc = last_updated_utc
		@closing_balance = closing_balance
		@debits_sum = debits_sum
		@debits_count = debits_count
		@credits_sum = credits_sum
		@credits_count = credits_count
		@currency_iso = currency_iso
		@transactions = transactions
	end

	def self.from_hash(hash)
		transactions = hash["Transactions"]
		transactions_parsed = nil
		unless (transactions.nil? || transactions.empty?)
			transactions_parsed = transactions.map{|item| FinancialTransaction::from_hash(item)}
		end

		return FinancialAccount.new(
			hash['AccountName'],
			hash['Holder'],
			hash['SortCode'],
			hash['AccountNumber'],
			hash['Type'],
			(Util::parse_dot_net_json_datetime(hash['FromDate']) rescue nil),
			(Util::parse_dot_net_json_datetime(hash['LastUpdatedUtc']) rescue nil),
			hash['ClosingBalance'],
			hash['DebitsSum'],
			hash['DebitsCount'],
			hash['CreditsSum'],
			hash['CreditsCount'],
			hash['CurrencyIso'],
			transactions_parsed
		)
	end
end

class FinancialCreditCard
	attr_accessor :account_name, :holder, :account_number, :type, :from_date, :last_updated_utc, :credit_limit
	attr_accessor :running_balance, :debits_sum, :debits_count, :credits_sum, :credits_count, :currency_iso
	attr_accessor :transactions

	def initialize(account_name, holder, account_number, type, from_date, last_updated_utc, credit_limit, running_balance, debits_sum, debits_count, credits_sum, credits_count, currency_iso, transactions)
		@account_name = account_name
		@holder = holder
		@account_number = account_number
		@type = type
		@from_date = from_date
		@last_updated_utc = last_updated_utc
		@credit_limit = credit_limit
		@running_balance = running_balance
		@debits_sum = debits_sum
		@debits_count = debits_count
		@credits_sum = credits_sum
		@credits_count = credits_count
		@currency_iso = currency_iso
		@transactions = transactions
	end

	def self.from_hash(hash)
		transactions = hash["Transactions"]
		transactions_parsed = nil
		unless (transactions.nil? || transactions.empty?)
			transactions_parsed = transactions.map{|item| FinancialTransaction::from_hash(item)}
		end

		return FinancialCreditCard.new(
			hash['AccountName'],
			hash['Holder'],
			hash['AccountNumber'],
			hash['Type'],
			(Util::parse_dot_net_json_datetime(hash['FromDate']) rescue nil),
			(Util::parse_dot_net_json_datetime(hash['LastUpdatedUtc']) rescue nil),
			hash['CreditLimit'],
			hash['RunningBalance'],
			hash['DebitsSum'],
			hash['DebitsCount'],
			hash['CreditsSum'],
			hash['CreditsCount'],
			hash['CurrencyIso'],
			transactions_parsed
		)
	end
end

class FinancialProvider
	attr_accessor :provider_name, :financial_accounts, :financial_credit_cards

	def initialize(provider_name, financial_accounts, financial_credit_cards)
		@provider_name = provider_name
		@financial_accounts = financial_accounts
		@financial_credit_cards = financial_credit_cards
	end

	def self.from_hash(hash)
		accounts = hash["FinancialAccounts"]
		accounts_parsed = nil
		unless (accounts.nil? || accounts.empty?)
			accounts_parsed = accounts.map{|item| FinancialAccount::from_hash(item)}
		end

		credit_cards = hash["FinancialCreditCards"]
		credit_cards_parsed = nil
		unless (credit_cards.nil? || credit_cards.empty?)
			credit_cards_parsed = credit_cards.map{|item| FinancialCreditCard::from_hash(item)}
		end

		return FinancialProvider.new(
			hash['ProviderName'],
			accounts_parsed,
			credit_cards_parsed
		)
	end
end

class MiiFinancialData
	attr_accessor :financial_providers

	def initialize(financial_providers)
		@financial_providers = financial_providers
	end

	def self.from_hash(hash)
		financial_providers = hash["FinancialProviders"]
		financial_providers_parsed = nil
		unless (financial_providers.nil? || financial_providers.empty?)
			financial_providers_parsed = financial_providers.map{|item| FinancialProvider::from_hash(item)}
		end

		return MiiFinancialData.new(
			financial_providers_parsed
		)
	end
end

class MiiUserProfile
	attr_accessor :username, :salutation, :first_name, :middle_name, :last_name
	attr_accessor :previous_first_name, :previous_middle_name, :previous_last_name
	attr_accessor :last_verified, :profile_url, :profile_short_url, :card_image_url, :email_addresses, :identities, :postal_addresses
	attr_accessor :phone_numbers, :web_properties, :identity_assured, :has_public_profile
	attr_accessor :public_profile, :date_of_birth, :qualifications, :age
	
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
		public_profile,
		date_of_birth,
		qualifications,
		age
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
		@date_of_birth = date_of_birth
		@qualifications = qualifications
		@age = age
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

		qualifications = hash["Qualifications"]
		qualifications_parsed = nil
		unless (qualifications.nil? || qualifications.empty?)
			qualifications_parsed = qualifications.map{|item| Qualification::from_hash(item)}
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
			Util::parse_dot_net_json_datetime(hash['LastVerified']),
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
			public_profile_parsed,
            (Util::parse_dot_net_json_datetime(hash['DateOfBirth']) rescue nil),
			qualifications_parsed,
			hash['Age']
			)			
	end
end

class MiiApiResponse
	attr_accessor :status, :error_code, :error_message, :is_test_user, :data
	
	def initialize(status, error_code, error_message, is_test_user, data)
		@status = status
		@error_code = error_code
		@error_message = error_message
		@is_test_user = is_test_user
		@data = data
	end
	
	def self.from_hash(hash, data_processor, array_type_payload = false)
		payload_json = hash["Data"]
		
		if payload_json && !data_processor.nil?
			if array_type_payload
				payload = payload_json.map{|item| data_processor.call(item)}
			else
				payload = data_processor.call(payload_json)
			end
		elsif !(payload_json.nil?)
			payload = payload_json
		else
			payload = nil
		end
			
		return MiiApiResponse.new(
			hash["Status"], 
			hash["ErrorCode"],
			hash["ErrorMessage"],
			hash["IsTestUser"],
			payload
		)
	end
end

class IdentitySnapshotDetails
	attr_accessor :snapshot_id, :username, :timestamp_utc, :was_test_user
	
	def initialize(snapshot_id, username, timestamp_utc, was_test_user)
		@snapshot_id = snapshot_id
		@username = username
		@timestamp_utc = timestamp_utc
		@was_test_user = was_test_user
	end
	
	def self.from_hash(hash)
		return IdentitySnapshotDetails.new(
			hash["SnapshotId"],
			hash["Username"],
			Util::parse_dot_net_json_datetime(hash["TimestampUtc"]),
			hash["WasTestUser"]
		)
	end
end

class IdentitySnapshot
	attr_accessor :details, :snapshot
	
	def initialize(details, snapshot)
		@details = details
		@snapshot = snapshot
	end
	
	def self.from_hash(hash)
		return IdentitySnapshot.new(
			IdentitySnapshotDetails::from_hash(hash["Details"]),
			MiiUserProfile::from_hash(hash["Snapshot"])
		)
	end
end

class MiiCardOAuthServiceBase
	attr_accessor :consumer_key, :consumer_secret, :access_token, :access_token_secret
	
	def initialize(consumer_key, consumer_secret, access_token, access_token_secret)
		if consumer_key.nil? || consumer_secret.nil? || access_token.nil? || access_token_secret.nil?
			raise ArgumentError
		end 

		@consumer_key = consumer_key
		@consumer_secret = consumer_secret
		@access_token = access_token
		@access_token_secret = access_token_secret
	end
	
	protected
	def make_request(url, post_data, payload_processor, wrapped_response, array_type_payload = false)
		consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, {:site => MiiCardServiceUrls::STS_SITE, :request_token_path => MiiCardServiceUrls::OAUTH_ENDPOINT, :access_token_path => MiiCardServiceUrls::OAUTH_ENDPOINT, :authorize_path => MiiCardServiceUrls::OAUTH_ENDPOINT })
		access_token = OAuth::AccessToken.new(consumer, @access_token, @access_token_secret)
				
		response = access_token.post(url, post_data.to_json(), { 'Content-Type' => 'application/json' })
		
		if wrapped_response
			return MiiApiResponse::from_hash(JSON.parse(response.body), payload_processor, array_type_payload)
		elsif !payload_processor.nil?
			return payload_processor.call(response.body)
		else
			return response.body
		end
	end
end

class MiiCardOAuthClaimsService < MiiCardOAuthServiceBase
	def initialize(consumer_key, consumer_secret, access_token, access_token_secret)
		super(consumer_key, consumer_secret, access_token, access_token_secret)
	end

	def get_method_url(method)
		return MiiCardServiceUrls.get_claims_method_url(method)
	end
	
	def get_claims
		return make_request(get_method_url('GetClaims'), nil, MiiUserProfile.method(:from_hash), true)
	end
	
	def is_social_account_assured(social_account_id, social_account_type)
		params = Hash["socialAccountId", social_account_id, "socialAccountType", social_account_type]
		
		return make_request(get_method_url('IsSocialAccountAssured'), params, nil, true)
	end
	
	def is_user_assured
		return make_request(get_method_url('IsUserAssured'), nil, nil, true)
	end
	
	def assurance_image(type)
		params = Hash["type", type]
		
		return make_request(get_method_url('AssuranceImage'), params, nil, false)
	end

	def get_card_image(snapshot_id, show_email_address, show_phone_number, format)
		params = Hash["SnapshotId", snapshot_id, "ShowEmailAddress", show_email_address, "ShowPhoneNumber", show_phone_number, "Format", format]
		
		return make_request(get_method_url('GetCardImage'), params, nil, false)
	end
		
	def get_identity_snapshot_details(snapshot_id = nil)
		params = Hash["snapshotId", snapshot_id]
		
		return make_request(get_method_url('GetIdentitySnapshotDetails'), params, IdentitySnapshotDetails.method(:from_hash), true, true)
	end
	
	def get_identity_snapshot(snapshot_id)
		params = Hash["snapshotId", snapshot_id]
		
		return make_request(get_method_url('GetIdentitySnapshot'), params, IdentitySnapshot.method(:from_hash), true)
	end

	def get_identity_snapshot_pdf(snapshot_id)
		params = Hash["snapshotId", snapshot_id]
		
		return make_request(get_method_url('GetIdentitySnapshotPdf'), params, nil, false)
	end

	def get_authentication_details(snapshot_id = nil)
		params = Hash["snapshotId", snapshot_id]

		return make_request(get_method_url('GetAuthenticationDetails'), params, AuthenticationDetails.method(:from_hash), true)
	end
end

class MiiCardOAuthFinancialService < MiiCardOAuthServiceBase
	def initialize(consumer_key, consumer_secret, access_token, access_token_secret)
		super(consumer_key, consumer_secret, access_token, access_token_secret)
	end	
	
	def get_method_url(method)
		return MiiCardServiceUrls.get_financial_method_url(method)
	end

	def is_refresh_in_progress
		return make_request(get_method_url('IsRefreshInProgress'), nil, nil, true)
	end

	def is_refresh_in_progress_credit_cards
		return make_request(get_method_url('IsRefreshInProgressCreditCards'), nil, nil, true)
	end

	def refresh_financial_data
		return make_request(get_method_url('RefreshFinancialData'), nil, FinancialRefreshStatus.method(:from_hash), true)
	end

	def refresh_financial_data_credit_cards
		return make_request(get_method_url('RefreshFinancialDataCreditCards'), nil, FinancialRefreshStatus.method(:from_hash), true)
	end

	def get_financial_transactions
		return make_request(get_method_url('GetFinancialTransactions'), nil, MiiFinancialData.method(:from_hash), true)
	end

	def get_financial_transactions_credit_cards
		return make_request(get_method_url('GetFinancialTransactionsCreditCards'), nil, MiiFinancialData.method(:from_hash), true)
	end
end

class MiiCardDirectoryService
	CRITERION_USERNAME = "username"
	CRITERION_EMAIL = "email"
	CRITERION_PHONE = "phone"
	CRITERION_TWITTER = "twitter"
	CRITERION_FACEBOOK = "facebook"
	CRITERION_LINKEDIN = "linkedin"
	CRITERION_GOOGLE = "google"
	CRITERION_MICROSOFT_ID = "liveid"
	CRITERION_EBAY = "ebay"
	CRITERION_VERITAS_VITAE = "veritasvitae"

	def find_by_email(email, hashed = false)
		return find_by(CRITERION_EMAIL, email, hashed)
	end

	def find_by_phone_number(phone, hashed = false)
		return find_by(CRITERION_PHONE, phone, hashed)
	end

	def find_by_username(username, hashed = false)
		return find_by(CRITERION_USERNAME, username, hashed)
	end

	def find_by_twitter(twitter_handle_or_profile_url, hashed = false)
		return find_by(CRITERION_TWITTER, twitter_handle_or_profile_url, hashed)
	end

	def find_by_facebook(facebook_url, hashed = false)
		return find_by(CRITERION_FACEBOOK, facebook_url, hashed)
	end

	def find_by_linkedin(linkedin_www_url, hashed = false)
		return find_by(CRITERION_LINKEDIN, linkedin_www_url, hashed)
	end

	def find_by_google(google_handle_or_profile_url, hashed = false)
		return find_by(CRITERION_GOOGLE, google_handle_or_profile_url, hashed)
	end

	def find_by_microsoft_id(microsoft_id_url, hashed = false)
		return find_by(CRITERION_MICROSOFT_ID, microsoft_id_url, hashed)
	end

	def find_by_ebay(ebay_handle_or_profile_url, hashed = false)
		return find_by(CRITERION_EBAY, ebay_handle_or_profile_url, hashed)
	end

	def find_by_veritas_vitae(veritas_vitae_vv_number_or_profile_url, hashed = false)
		return find_by(CRITERION_VERITAS_VITAE, veritas_vitae_vv_number_or_profile_url, hashed)
	end

	def find_by(criterion, value, hashed = false)
		url = MiiCardServiceUrls::get_directory_service_query_url(criterion, value, hashed)
		uri = URI.parse(url)

		cert_store = OpenSSL::X509::Store.new
		cert_store.set_default_paths

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.cert_store = cert_store
		http.ca_file = File.join(File.dirname(__FILE__), "certs/sts.miicard.com.pem")

		request = Net::HTTP::Get.new(url)
		request['Content-type'] = 'application/json'
		
		response = (http.request(request) rescue nil)

		if !response.nil? && !response.body.to_s.empty?
			# Try parsing the response as a MiiApiResponse of MiiUserProfile
			parsed_response = (MiiApiResponse::from_hash(JSON.parse(response.body), MiiUserProfile.method(:from_hash)) rescue nil)
			if !parsed_response.nil? && !parsed_response.data.nil?
				to_return = parsed_response.data
			end
		end

		return to_return
	end
	
	def self.hash_identifier(identifier)
		return Digest::SHA1.hexdigest(identifier.downcase)
	end
end

class Util
	# Modified from http://stackoverflow.com/questions/1272195/c-sharp-serialized-json-date-to-ruby
	def self.parse_dot_net_json_datetime(datestring)
	  seconds_since_epoch = (datestring.scan(/[0-9]+/)[0].to_i) / 1000.0
	  return DateTime.strptime(seconds_since_epoch.to_s, '%s')
	end
end
