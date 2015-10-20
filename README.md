# SimpleCadet Webservice
[ ![Codeship Status for ISS-SOA/simple_cadet](https://codeship.io/projects/e1d4f690-44bc-0132-a4ed-52edbda4e693/status?branch=master)](https://codeship.io/projects/44861)

A simple version of web service that scrapes CodeCademy data using the
[codebadges](https://github.com/ISS-SOA/Codecademy-Ruby) gem

Handles:
- GET   /
  - returns OK status to indicate service is alive
- GET   /api/v1/cadet/<username>.json
  - returns JSON of user info: id (name), type, badges
- POST  /api/v1/check
  - takes JSON: array of 'usernames', array of 'badges'
  - returns: array of users and their missing badges
