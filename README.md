api-wrappers-ruby
=================

Ruby wrapper classes around the miiCard API.

This repository houses the source for the latest version of the miiCard Consumers library available on [RubyGems.org](http://rubygems.org).

##What is miiCard
miiCard lets anybody prove their identity to the same level of traceability as using a passport, driver's licence or photo ID. We then allow external web applications to ask miiCard users to share a portion of their identity information with the application through a web-accessible API.

##What is the library for?
miiCard's API is an OAuth-protected web service supporting SOAP, POX and JSON - [documentation](http://www.miicard.com/developers) is available. The library wraps the JSON endpoint of the API, making it easier to make the required OAuth signed requests. 

You can obtain a consumer key and secret from miiCard by contacting us on our support form, including the details listed on the developer site.

Pull the library into your own application by downloading the latest released version from RubyGems.org.

##Usage

You'll need to implement your own OAuth exchange with miiCard.com's OAuth endpoint to obtain an access token and secret for a user. Once you've got your consumer key and secret, access token and access token secret you can instantiate an API wrapper:

    api = MiiCardOAuthClaimsService.new("consumer_key", "consumer_secret", "access_token", "access_token_secret")

Then make calls against it simply:

    user_profile_response = api.get_claims().data
    
    user_first_name = user_profile_response.data.first_name

##Mapping from API data types
The following list is provided as a convenient cheat-sheet, and maps the API's methods and data types to their equivalents in the Ruby wrapper library classes.

###Methods
<table>
<tr><th>API method</td><th>Ruby equivalent (given `api` instance of MiiCardOAuthClaimsService)</th></tr>
<tr><td>AssuranceImage</td><td>api.assurance_image(type)</td></tr>
<tr><td>GetClaims</td><td>api.get_claims()</td></tr>
<tr><td>GetIdentitySnapshot</td><td>api.get_identity_snapshot(snapshot_id)</td></tr>
<tr><td>GetIdentitySnapshotPdf</td><td>api.get_identity_snapshot_pdf(snapshot_id)</td></tr>
<tr><td>GetIdentitySnapshotDetails</td><td>api.get_identity_snapshot_details()<br /><b>Or, for a specific snapshot:</b><br />api.get_identity_snapshot_details(snapshot_id)</td></tr>
<tr><td>IsSocialAccountAssured</td><td>api.is_social_account_assured(social_account_id, social_account_type)</td></tr>
<tr><td>IsUserAssured</td><td>api.is_user_assured()</td></tr>
</table>

###Data types

####EmailAddress
<table>
<tr><th>API data-type property</td><th>Ruby equivalent (given `email` instance of EmailAddress)</th></tr>
<tr><td>DisplayName</td><td>email.display_name</td></tr>
<tr><td>Address</td><td>email.address</td></tr>
<tr><td>IsPrimary</td><td>email.is_primary</td></tr>
<tr><td>Verified</td><td>email.verified</td></tr>
</table>

####Identity
<table>
<tr><th>API data-type property</td><th>Ruby equivalent (given `identity` instance of Identity)</th></tr>
<tr><td>Source</td><td>identity.source</td></tr>
<tr><td>UserId</td><td>identity.user_id</td></tr>
<tr><td>ProfileUrl</td><td>identity.profile_url</td></tr>
<tr><td>Verified</td><td>identity.verified</td></tr>
</table>

####IdentitySnapshot
<table>
<tr><th>API data-type property</td><th>Ruby equivalent (given `snapshot` instance of IdentitySnapshot)</th></tr>
<tr><td>Details</td><td>snapshot.details</td></tr>
<tr><td>Snapshot</td><td>snapshot.snapshot</td></tr>
</table>

####IdentitySnapshotDetails
<table>
<tr><th>API data-type property</td><th>Ruby equivalent (given `snapshot_details` instance of IdentitySnapshotDetails)</th></tr>
<tr><td>SnapshotId</td><td>snapshot_details.snapshot_id</td></tr>
<tr><td>Username</td><td>snapshot_details.username</td></tr>
<tr><td>TimestampUtc</td><td>snapshot_details.timestamp_utc</td></tr>
<tr><td>WasTestUser</td><td>snapshot_details.was_test_user</td></tr>
</table>

####MiiApiCallStatus enumeration type
<table>
<tr><th>API data-type property</td><th>Ruby equivalent</th></tr>
<tr><td>Success</td><td>MiiApiCallStatus.SUCCESS</td></tr>
<tr><td>Failure</td><td>MiiApiCallStatus.FAILURE</td></tr>
</table>

####MiiApiErrorCode enumeration type
<table>
<tr><th>API data-type property</td><th>Ruby equivalent</th></tr>
<tr><td>Success</td><td>MiiApiCallStatus.SUCCESS</td></tr>
<tr><td>AccessRevoked</td><td>MiiApiCallStatus.ACCESS_REVOKED</td></tr>
<tr><td>UserSubscriptionLapsed</td><td>MiiApiCallStatus.USER_SUBSCRIPTION_LAPSED</td></tr>
<tr><td>TransactionalSupportDisabled</td><td>MiiApiCallStatus.TRANSATIONAL_SUPPORT_DISABLED</td></tr>
<tr><td>DevelopmentTransactionalSupportOnly</td><td>MiiApiCallStatus.DEVELOPMENT_TRANSACTIONAL_SUPPORT_ONLY</td></tr>
<tr><td>InvalidSnapshotId</td><td>MiiApiCallStatus.INVALID_SNAPSHOT_ID</td></tr>
<tr><td>Blacklisted</td><td>MiiApiCallStatus.BLACKLISTED</td></tr>
<tr><td>ProductDisabled</td><td>MiiApiCallStatus.PRODUCT_DISABLED</td></tr>
<tr><td>ProductDeleted</td><td>MiiApiCallStatus.PRODUCT_DELETED</td></tr>
<tr><td>Exception</td><td>MiiApiCallStatus.EXCEPTION</td></tr>
</table>

####MiiApiResponse
<table>
<tr><th>API data-type property</td><th>Ruby equivalent (given `response` instance of MiiApiResponse)</th></tr>
<tr><td>Status</td><td>response.status</td></tr>
<tr><td>ErrorCode</td><td>response.error_code</td></tr>
<tr><td>ErrorMessage</td><td>response.error_message</td></tr>
<tr><td>Data</td><td>response.data</td></tr>
<tr><td>IsTestUser</td><td>response.is_test_user</td></tr>
</table>

####MiiUserProfile
<table>
<tr><th>API data-type property</td><th>Ruby equivalent (given `profile` instance of MiiUserProfile)</th></tr>
<tr><td>Salutation</td><td>profile.salutation</td></tr>
<tr><td>FirstName</td><td>profile.first_name</td></tr>
<tr><td>MiddleName</td><td>profile.middle_name</td></tr>
<tr><td>LastName</td><td>profile.last_name</td></tr>
<tr><td>DateOfBirth</td><td>profile.date_of_birth</td></tr>
<tr><td>PreviousFirstName</td><td>profile.previous_first_name</td></tr>
<tr><td>PreviousMiddleName</td><td>profile.previous_middle_name</td></tr>
<tr><td>PreviousLastName</td><td>profile.previous_last_name</td></tr>
<tr><td>LastVerified</td><td>profile.last_verified</td></tr>
<tr><td>ProfileUrl</td><td>profile.profile_url</td></tr>
<tr><td>ProfileShortUrl</td><td>profile.profile_short_url</td></tr>
<tr><td>CardImageUrl</td><td>profile.card_image_url</td></tr>
<tr><td>EmailAddresses</td><td>profile.email_addresses</td></tr>
<tr><td>Identities</td><td>profile.identities</td></tr>
<tr><td>PhoneNumbers</td><td>profile.phone_numbers</td></tr>
<tr><td>PostalAddresses</td><td>profile.postal_addresses</td></tr>
<tr><td>WebProperties</td><td>profile.web_properties</td></tr>
<tr><td>IdentityAssured</td><td>profile.identity_assured</td></tr>
<tr><td>HasPublicProfile</td><td>profile.has_public_profile</td></tr>
<tr><td>PublicProfile</td><td>profile.public_profile</td></tr>
</table>

####PhoneNumber
<table>
<tr><th>API data-type property</td><th>Ruby equivalent (given `phone` instance of PhoneNumber)</th></tr>
<tr><td>DisplayName</td><td>phone.display_name</td></tr>
<tr><td>CountryCode</td><td>phone.country_code</td></tr>
<tr><td>NationalNumber</td><td>phone.national_number</td></tr>
<tr><td>IsMobile</td><td>phone.is_mobile</td></tr>
<tr><td>IsPrimary</td><td>phone.is_primary</td></tr>
<tr><td>Verified</td><td>phone.verified</td></tr>
</table>

####PostalAddress
<table>
<tr><th>API data-type property</td><th>Ruby equivalent (given `address` instance of PostalAddress)</th></tr>
<tr><td>House</td><td>address.house</td></tr>
<tr><td>Line1</td><td>address.line1</td></tr>
<tr><td>Line2</td><td>address.line2</td></tr>
<tr><td>City</td><td>address.city</td></tr>
<tr><td>Region</td><td>address.region</td></tr>
<tr><td>Code</td><td>address.code</td></tr>
<tr><td>Country</td><td>address.country</td></tr>
<tr><td>IsPrimary</td><td>address.is_primary</td></tr>
<tr><td>Verified</td><td>address.verified</td></tr>
</table>

####WebProperty
<table>
<tr><th>API data-type property</td><th>Ruby equivalent (given `property` instance of WebProperty)</th></tr>
<tr><td>DisplayName</td><td>property.display_name</td></tr>
<tr><td>Identifier</td><td>property.identifier</td></tr>
<tr><td>Type</td><td>property.type</td></tr>
<tr><td>Verified</td><td>property.verified</td></tr>
</table>

####WebPropertyType enumeration type
<table>
<tr><th>API data-type property</td><th>Ruby equivalent</th></tr>
<tr><td>Domain</td><td>WebPropertyType.DOMAIN</td></tr>
<tr><td>Website</td><td>WebPropertyType.WEBSITE</td></tr>
</table>

##Dependencies
The library takes a dependency on the [Ruby OAuth Gem](http://oauth.rubyforge.org/).

##Contributing
* Use GitHub issue tracking to report bugs in the library
* If you're going to submit a patch, please base it off the development branch - the master reflects the latest version published to RubyGems.org but may not necessarily be bleeding-edge
* Join the [miiCard.com developer forums](http://devforum.miicard.com) to keep up to date with the latest releases and planned changes

##Licence
Copyright (c) 2012, miiCard Limited All rights reserved.

http://opensource.org/licenses/BSD-3-Clause

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

- Neither the name of miiCard Limited nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.