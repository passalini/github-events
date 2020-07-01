# Github events
Project to save and filter github events using webhooks

# Getting Started

To run this project on your machine you only need to follow those steps:

1. Install Postgres
2. Install ngrok
3. Run `bundle install`
4. Run `rake db:create`
5. Run `rake db:migrate`
6. Run `ngrok http 3000`. It will build the url to use at the next step.
7. Run `SECRET_TOKEN=ANY-TOKEN NGROK_URL=NGROK-URL rails s`

The project index will show all repositories created by events triggered by Github and some settings to configure the webhooks at Github.

# Testing

All tests were made with Rails native suite test, to run it you need to use this command:

`rails test`

# API

It only have two endpoints:

1. `/events`. Used to create events from hooks
2. `issues/:issue_id/events`. Paginated endpoint to list all events from an issue.
