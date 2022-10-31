Gem::Specification.new do |s|
  s.name = 'kjlite'
  s.version = '0.3.0'
  s.summary = 'kjlist is a lightweight version of the kj gem for accessing ' +
      'the King James Bible. It downloads the text file from gutenberg.org.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/kjlite.rb']
  s.add_runtime_dependency('novowels', '~> 0.1', '>=0.1.3')
  s.signing_key = '../privatekeys/kjlite.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/kjlite'
end
