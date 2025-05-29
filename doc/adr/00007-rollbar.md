# 7. Use Rollbar

Date: 2025-05-28

## Status

Accepted

## Context

We need a robust error tracking and monitoring solution for our application to ensure we can quickly identify and respond to any issues that affect our users.

## Decision

We will use Rollbar for error tracking and monitoring. This will be integrated into the Rails application using the rollbar gem, with appropriate email notification alerts configured for critical errors.

## Consequences

Rollbar provides real-time error tracking and alerting, giving us immediate visibility into any issues that occur in production. The service captures detailed error context and stack traces, making it easier to diagnose and fix problems quickly.

The integration with our existing deployment workflow is straightforward, as Rollbar is available as a Heroku add-on. This simplifies our infrastructure setup and maintenance.

Rollbar's free tier has limited error tracking capacity, which could be insufficient if we experience a high volume of errors. The service's pricing scales with error volume, which could become costly if we don't properly manage error logging.

We need to be careful about what data we log to avoid exposing sensitive information. While Rollbar provides tools to scrub sensitive data, we must ensure our implementation correctly handles this.

The service adds another external dependency to our application. While Rollbar is reliable, any issues with their service could impact our ability to monitor our application effectively.
