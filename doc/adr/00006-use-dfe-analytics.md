# 6. Use DfE Analytics

Date: 2025-05-28

## Status

Accepted

## Context

We need to track user behavior and gather analytics data for the application. We need a solution that aligns with DfE standards and provides meaningful insights without collecting Personally Identifiable Information (PII).

## Decision

We will implement DfE Analytics using the dfe-analytics gem, which provides a standardized way to track user interactions and stores data in BigQuery within the GHBS GCP project. This gem provides a framework for tracking both frontend and backend user activity, with customizable event tracking capabilities.

## Consequences

The DfE Analytics gem provides a standardized approach to analytics tracking across DfE applications, reducing development effort and ensuring consistency. While it doesn't automatically track frontend activity, it provides a simple API for implementing custom event tracking.

The solution operates server-side, collecting data directly from the application server and sending it to BigQuery. This approach eliminates the need for client-side cookies or JavaScript tracking, making it inherently compliant with privacy regulations and cookie policies. 

The data is stored securely in BigQuery within the GHBS GCP project, providing a centralized location for analytics data across DfE services. This enables cross-service analysis and reporting capabilities.

Initially, we encountered a challenge as the gem assumed the existence of a database and ActiveRecord. We contributed to the gem by adding support for applications without ActiveRecord, making it possible to use in our database-less application. This contribution benefits other DfE applications that might need similar functionality.

However, this approach has some limitations. The anonymized identifiers may not provide perfect user tracking, especially for users behind shared IP addresses. 

We also need to ensure our team has the necessary skills to effectively query and analyze the data in BigQuery.

The gem's customizable nature allows us to track exactly what we need, but this requires careful configuration to balance insights with efficiency. We need to be deliberate about what events we track to avoid unnecessary storage costs.