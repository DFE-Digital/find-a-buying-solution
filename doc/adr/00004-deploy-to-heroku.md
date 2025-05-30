# 4. Deploy to Heroku

Date: 2025-05-30

## Status

Accepted

## Context

This is a simple non-transactional Ruby on Rails application that primarily serves as a catalogue of buying solutions. The application has modest traffic requirements, with maximum daily visits around 400. We need a deployment solution that balances operational simplicity with cost-effectiveness.

The application uses Redis for background jobs and session management, but has no database requirements. All content is managed through Contentful, and we use GitHub Actions for Continuous Integration and Continuous Deployment.

## Decision

We will deploy the application to Heroku using their standard Ruby on Rails buildpack. We will use Heroku's basic dynos for development and production, with automatic review apps for pull requests and staging environments through Heroku's pipeline feature.

## Consequences

The deployment to Heroku reduces operational overhead as it handles infrastructure and SSL/TLS.

The Basic tier is sufficient for our expected load, keeping costs minimal. The simplified deployment process through Heroku's git integration streamlines our workflow.

Heroku's marketplace provides many add-ons at low or no cost, such as Rollbar for error tracking, which we are already using.

While we have limited control over infrastructure configuration compared to Microsoft Azure or Amazon Web Services, this trade-off is acceptable given our needs. The platform allows horizontal scaling through additional dynos if needed.
