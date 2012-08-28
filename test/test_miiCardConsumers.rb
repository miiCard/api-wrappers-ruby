require 'json'
require 'miiCardConsumers'
require 'test/unit'

class TestSomething < Test::Unit::TestCase
	def setup
		@jsonBody = '{"CardImageUrl":"https:\/\/my.miicard.com\/img\/test.png","EmailAddresses":[{"Verified":true,"Address":"test@example.com","DisplayName":"testEmail","IsPrimary":true},{"Verified":false,"Address":"test2@example.com","DisplayName":"test2Email","IsPrimary":false}],"FirstName":"Test","HasPublicProfile":true,"Identities":null,"IdentityAssured":true,"LastName":"User","LastVerified":"\/Date(1345812103)\/","MiddleName":"Middle","PhoneNumbers":[{"Verified":true,"CountryCode":"44","DisplayName":"Default","IsMobile":true,"IsPrimary":true,"NationalNumber":"7800123456"},{"Verified":false,"CountryCode":"44","DisplayName":"Default","IsMobile":false,"IsPrimary":false,"NationalNumber":"7800123457"}],"PostalAddresses":[{"House":"Addr1 House1","Line1":"Addr1 Line1","Line2":"Addr1 Line2","City":"Addr1 City","Region":"Addr1 Region","Code":"Addr1 Code","Country":"Addr1 Country","IsPrimary":true,"Verified":true},{"House":"Addr2 House1","Line1":"Addr2 Line1","Line2":"Addr2 Line2","City":"Addr2 City","Region":"Addr2 Region","Code":"Addr2 Code","Country":"Addr2 Country","IsPrimary":false,"Verified":false}],"PreviousFirstName":"PrevFirst","PreviousLastName":"PrevLast","PreviousMiddleName":"PrevMiddle","ProfileShortUrl":"http:\/\/miicard.me\/123456","ProfileUrl":"https:\/\/my.miicard.com\/card\/test","PublicProfile":{"CardImageUrl":"https:\/\/my.miicard.com\/img\/test.png","FirstName":"Test","HasPublicProfile":true,"IdentityAssured":true,"LastName":"User","LastVerified":"\/Date(1345812103)\/","MiddleName":"Middle","PreviousFirstName":"PrevFirst","PreviousLastName":"PrevLast","PreviousMiddleName":"PrevMiddle","ProfileShortUrl":"http:\/\/miicard.me\/123456","ProfileUrl":"https:\/\/my.miicard.com\/card\/test","PublicProfile":null,"Salutation":"Ms","Username":"testUser"},"Salutation":"Ms","Username":"testUser","WebProperties":[{"Verified":true,"DisplayName":"example.com","Identifier":"example.com","Type":0},{"Verified":false,"DisplayName":"2.example.com","Identifier":"http:\/\/www.2.example.com","Type":1}]}'
		@jsonResponseBody = '{"ErrorCode":0,"Status":0,"ErrorMessage":"A test error message","Data":true}'
	end

	def test_can_deserialise_user_profile
		o = MiiUserProfile.from_hash(JSON.parse(@jsonBody))

        assertBasics(o)

        # Email addresses
        email1 = o.email_addresses[0]
        assert_equal(true, email1.verified)
        assert_equal("test@example.com", email1.address)
        assert_equal("testEmail", email1.display_name)
        assert_equal(true, email1.is_primary)

        email2 = o.email_addresses[1]
        assert_equal(false, email2.verified)
        assert_equal("test2@example.com", email2.address)
        assert_equal("test2Email", email2.display_name)
        assert_equal(false, email2.is_primary)

        # Phone numbers
        phone1 = o.phone_numbers[0]
        assert_equal(true, phone1.verified)
        assert_equal("44", phone1.country_code)
        assert_equal("Default", phone1.display_name)
        assert_equal(true, phone1.is_mobile)
        assert_equal(true, phone1.is_primary)
        assert_equal("7800123456", phone1.national_number)

        phone2 = o.phone_numbers[1]
        assert_equal(false, phone2.verified)
        assert_equal("44", phone2.country_code)
        assert_equal("Default", phone2.display_name)
        assert_equal(false, phone2.is_mobile)
        assert_equal(false, phone2.is_primary)
        assert_equal("7800123457", phone2.national_number)

        # Web properties
        prop1 = o.web_properties[0]
        assert_equal(true, prop1.verified)
        assert_equal("example.com", prop1.display_name)
        assert_equal("example.com", prop1.identifier)
        assert_equal(WebPropertyType::DOMAIN, prop1.type)

        prop2 = o.web_properties[1]
        assert_equal(false, prop2.verified)
        assert_equal("2.example.com", prop2.display_name)
        assert_equal("http://www.2.example.com", prop2.identifier)
        assert_equal(WebPropertyType::WEBSITE, prop2.type) 

        # Postal addresses
        addr1 = o.postal_addresses[0]
        assert_equal("Addr1 House1", addr1.house)
        assert_equal("Addr1 Line1", addr1.line1)
        assert_equal("Addr1 Line2", addr1.line2)
        assert_equal("Addr1 City", addr1.city)
        assert_equal("Addr1 Region", addr1.region)
        assert_equal("Addr1 Code", addr1.code)
        assert_equal("Addr1 Country", addr1.country)
        assert_equal(true, addr1.is_primary)
        assert_equal(true, addr1.verified)

        addr2 = o.postal_addresses[1]
        assert_equal("Addr2 House1", addr2.house)
        assert_equal("Addr2 Line1", addr2.line1)
        assert_equal("Addr2 Line2", addr2.line2)
        assert_equal("Addr2 City", addr2.city)
        assert_equal("Addr2 Region", addr2.region)
        assert_equal("Addr2 Code", addr2.code)
        assert_equal("Addr2 Country", addr2.country)
        assert_equal(false, addr2.is_primary)
        assert_equal(false, addr2.verified)

        assert_equal(true, o.has_public_profile)
        
        pp = o.public_profile
        assertBasics(pp)
        assert_equal("testUser", pp.username)
	end

	def assertBasics(obj)
		assert_not_nil(obj)
		        
        assert_equal("https://my.miicard.com/img/test.png", obj.card_image_url)
        assert_equal("Test", obj.first_name)
        assert_equal("Middle", obj.middle_name)
        assert_equal("User", obj.last_name)
        
        assert_equal("PrevFirst", obj.previous_first_name)
        assert_equal("PrevMiddle", obj.previous_middle_name)
        assert_equal("PrevLast", obj.previous_last_name)

        assert_equal(true, obj.identity_assured)
        assert_equal("/Date(1345812103)/", obj.last_verified)

        assert_equal(true, obj.has_public_profile)
        assert_equal("http://miicard.me/123456", obj.profile_short_url)
        assert_equal("https://my.miicard.com/card/test", obj.profile_url)
        assert_equal("Ms", obj.salutation)
        assert_equal("testUser", obj.username)
	end

	def test_can_deserialise_boolean
        o = MiiApiResponse.from_hash(JSON.parse(@jsonResponseBody), nil)

        assert_equal(MiiApiCallStatus::SUCCESS, o.status)
        assert_equal(MiiApiErrorCode::SUCCESS, o.error_code)
        assert_equal("A test error message", o.error_message)
        assert_equal(true, o.data)
	end

	def test_wrapper_throws_on_null_consumer_key
		assert_raise ArgumentError do
			MiiCardOAuthClaimsService.new(nil, "ConsumerSecret", "AccessToken", "AccessTokenSecret")
		end

		assert_raise ArgumentError do
			MiiCardOAuthClaimsService.new("ConsumerKey", nil, "AccessToken", "AccessTokenSecret")
		end

		assert_raise ArgumentError do
			MiiCardOAuthClaimsService.new("ConsumerKey", "ConsumerSecret", nil, "AccessTokenSecret")
		end

		assert_raise ArgumentError do
			MiiCardOAuthClaimsService.new("ConsumerKey", "ConsumerSecret", "AccessToken", nil)
		end
	end
end