Gem::Specification.new do |s|
  s.name        = 'miiCardConsumers'
  s.version     = '2.5.0'
  s.date        = '2014-02-26'
  s.summary     = "Wrapper library around the miiCard API."
  s.description = "A simple wrapper library around the miiCard API that makes calling into it easier - just new up a MiiApiOAuthClaimsService with your consumer key, secret, access token and secret and start calling methods."
  s.authors     = ["Paul O'Neill", "Peter Sanderson"]
  s.email       = 'info@miicard.com'
  s.files       = ["lib/miiCardConsumers.rb", "lib/certs/sts.miicard.com.pem"]
  s.test_files  = ["test/test_miiCardConsumers.rb"]
  s.homepage    = 'http://www.miicard.com/developers'

  s.license     = 'BSD'
 
  s.add_dependency "oauth"
  s.add_dependency "json"
end