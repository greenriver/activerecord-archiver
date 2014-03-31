Gem::Specification.new do |s|
  s.name        = 'activerecord-archiver'
  s.version     = '0.0.0'
  s.date        = '2014-02-05'
  s.summary     = "A simle tool for exporting/importing subsets of activerecord tables as JSON."
  s.description = <<DESC
ActiveRecord-Archiver is a simple tool for taking a subset of the records in one environment
and exporting them for use in another environment.

Design Constraints:
- leave out ids so as not to create collisions in the new environment
- preserve relations between records
- Allow for cyclic relationships
DESC
  s.authors     = ['Sam Auciello']
  s.email       = 'sam@greenriver.com'
  s.files       = ['lib/activerecord-archiver.rb',
                   'lib/activerecord-archiver/archiver.rb',
                   'lib/activerecord-archiver/export.rb',
                   'lib/activerecord-archiver/import.rb']
  s.homepage    = 'https://github.com/greenriver/activerecord-archiver'
  s.license     = 'MIT'
end