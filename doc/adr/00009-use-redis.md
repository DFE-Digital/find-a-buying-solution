# 9. Use Redis

Date: 2025-05-28

## Status

Accepted

## Context

Our application needs a solution for caching and storing Sidekiq background jobs data. Since we don't use a relational database, we need a lightweight, fast data store that can handle these requirements.

## Decision

We will use Redis for caching and background jobs data storage. Redis is the default choice of data storage for our job queue adapter Sidekiq and is also a great solution for caching. We will use the Heroku Key-Value Store add-on for hosting, which is compatible with Redis.

## Consequences

Redis provides fast, in-memory data access which is ideal for our background jobs and temporary storage needs. The service is well-supported on Heroku and integrates easily with our Rails application through the sidekiq gem.

Using Redis as a Heroku add-on simplifies our infrastructure management. The service is automatically provisioned and configured, reducing operational overhead. The integration with our existing Heroku deployment workflow is seamless.

Redis is an in-memory data store, which means data is not persisted to disk by default. While this is acceptable for our use case of background jobs and temporary storage, we need to be aware that data could be lost if the Redis instance restarts.

The Heroku Key-Value Store add-on has cost implications that scale with our usage. While the Mini tier is sufficient for our current needs, we need to monitor our usage to ensure we don't exceed the tier limits or need to upgrade to a more expensive plan.

The service adds another external dependency to our application. While Redis is reliable, any issues with the Heroku Key-Value Store service could impact our background job processing and temporary data storage capabilities. 