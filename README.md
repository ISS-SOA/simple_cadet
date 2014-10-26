# SimpleCadet Webservice

A simple version of [chenlizhan](https://github.com/ChenLiZhan)'s [codecadet](https://github.com/ISS-SOA/codecadet) web application and service.

Handles:
- GET   /api/v1/cadet/<username>.json
  - returns JSON of user info: id (name), type, badges
- POST  /api/v1/check
  - takes JSON: array of 'usernames', array of 'badges'
  - returns: array of users and their missing badges
