# 8. Use Sidekiq

Date: 2025-05-30

## Status

Accepted

## Context

Our application needs a reliable solution for processing background jobs, specifically for handling DfE Analytics data submission and Rollbar error tracking. Since we don't use a relational database, we need a background job processor that can work with our existing infrastructure. The application has modest traffic requirements, with maximum daily visits around 400, but we need to ensure these tracking tasks don't impact the user experience.

## Decision

We will use Sidekiq for background job processing. This will be integrated with Redis to handle asynchronous tasks, ensuring our application remains responsive to user requests while reliably processing analytics and error tracking data.

## Consequences

Sidekiq provides a robust solution for background job processing, with excellent integration with Ruby on Rails. The service allows us to move non-critical tasks like analytics and error tracking out of the main request cycle, ensuring they don't impact the core user journey.

As Sidekiq requires Redis as its backend, this decision also means we need to maintain a Redis instance. This adds an additional infrastructure component to our stack, but one that is well-supported on Heroku and integrates easily with our application.

This approach requires an additional Heroku dyno dedicated to running Sidekiq workers. While this increases our infrastructure costs, it ensures that background job processing doesn't compete with web requests for resources.

The service adds another external dependency to our application. While Sidekiq is well-maintained and widely used, we need to ensure we keep it updated and monitor its performance.

