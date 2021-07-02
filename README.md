## Description
A Ruby wrapper for OpenSLP using FFI.

## Installation
`gem install rslp`

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
