## Description
A Ruby wrapper for OpenSLP using FFI.

## Installation
`gem install rslp`

## Adding the trusted cert
`gem cert --add <(curl -Ls https://raw.githubusercontent.com/djberg96/rslp/main/certs/djberg96_pub.pem)`

## Synopsis
```ruby
require 'rslp'

OpenSLP::SLP.new do |slp|
  # See docs for more methods
  p slp.find_services
  p slp.find_scopes
end
```

## Known Bugs
None that I'm aware of. Please report bugs on the project page at:

https://github.com/djberg96/rslp

## Future Plans
None at this time.

## Maintenance
Please contact me about taking over maintenance of this library if you are
interested. I'm not actually using it myself, and have no real plans to update
it.

Why then? I originally wrote most of this when I thought we might need it
for a project at work. That never materialized, but I hated to let it go to
waste, so I've published what I completed.

## License
Apache-2.0

## Copyright
(C) 2003-2021 Daniel J. Berger, All Rights Reserved

## Warranty
This package is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.

## Author
Daniel J. Berger
