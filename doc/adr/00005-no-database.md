# 5. Don't use a relational database

Date: 2025-05-28

## Status

Accepted

## Context

This application serves as a catalogue of buying solutions that visitors can browse and visit via links to external sites. The primary content is managed through Contentful, which provides both the content management interface and data storage. The application has modest traffic requirements, with maximum daily visits around 400.

We need to consider how to handle application state and any temporary data storage requirements.

## Decision

We will not use a database in this application. All content will be managed through Contentful, and any application state will be handled through Redis for caching and temporary data storage for background jobs.

## Consequences

The absence of a database significantly reduces our infrastructure complexity and maintenance overhead. We eliminate the need for database backups, migrations, and associated operational tasks.

We rely entirely on Contentful for data persistence, which aligns with our content-focused architecture. This dependency is mitigated by Contentful's API, which allows us to export all data if we need to migrate away in the future.

Redis will handle our background jobs data and caching needs, reducing load on the Contentful API.

The stateless nature of our application allows for easy horizontal scaling, as we can add more application servers (Heroku dynos) without database coordination.

We may need to add a database in the future if we need to store user-generated data or implement features requiring complex data relationships. For example, we cannot implement user accounts or form submissions.
