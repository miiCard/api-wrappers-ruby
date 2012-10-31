Gem::Specification.new do |s|
  s.name        = 'miiCardConsumers'
  s.version     = '1.1.0'
  s.date        = '2012-10-31'
  s.summary     = "Wrapper library around the miiCard API."
  s.description = "A simple wrapper library around the miiCard API that makes calling into it easier - just new up a MiiApiOAuthClaimsService with your consumer key, secret, access token and secret and start calling methods."
  s.authors     = ["Paul O'Neill"]
  s.email       = 'paul.oneill@miicard.com'
  s.files       = ["lib/miiCardConsumers.rb"]
  s.test_files  = ["test/test_miiCardConsumers.rb"]
  s.homepage    = 'http://www.miicard.com/developers'
 
  s.add_dependency "oauth"
  s.add_dependency "json"
end