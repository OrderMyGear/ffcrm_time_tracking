$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ffcrm_time_tracking/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ffcrm_time_tracking"
  s.version     = FfcrmTimeTracking::VERSION
  s.authors     = ["Alex Eliseev"]
  s.email       = ["elja1989@gmail.com"]
  s.summary     = "Adds time tracking to fat free crm"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_development_dependency 'pg'

  s.add_dependency 'fat_free_crm'
  s.add_dependency 'timespan'
  s.add_dependency 'ffcrm_project_management'
end
