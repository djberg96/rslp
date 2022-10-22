## 0.1.1 - 22-Oct-2022
* Added many more specs, along with instructions for how to install and
  run an openslp container via Docker so that you can run the specs.
* The :url parameter to the register method now raises an error unless
  it is present. It was always required in practice, but now it's enforced.
* Many documentation updates, notably that some methods may not actually
  be implemented yet by the underlying OpenSLP library.

## 0.1.0 - 19-Oct-2022
* Updated the constructor, now uses keyword arguments.
* Constructor now accepts a hostname, or a comma separate lists of hosts.
* Added the set_app_property_file singleton method.
* Changed the deregister method to return the url.
* Minor refactoring of callback procs.

## 0.0.2 - 12-Oct-2022
* Fixed the parse_service_url singleton method. The underlying SLPSrvURL
  struct is now a managed struct.
* Added some nicer method aliases to the SLPSrvURL struct.
* Refactored the underlying C function wrappers to return an SLPError enum
  to more closely align with the API.
* Any internal function failures now raise an OpenSLP::SLP::Error instead
  of a SystemCallError. The error message has also been improved.

## 0.0.1 - 2-Jul-2021
* Initial release
