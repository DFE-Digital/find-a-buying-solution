# 3. Use Contentful

Date: 2025-01-30

## Status

Accepted

## Context

This application is principally a catalogue of buying solutions that visitors
can browse and visit via links out to external sites.

We need a content management system to enter and maintain the content.

Contentful is a hosted content management system (CMS) that DfE already
uses. One of its marketed and well-established applications is as the content
API for online retailers. This has a lot in common with our application.

Contentful provides an editing interface for both schema and data, user
administration, and asset uploading and delivery. There is a vendor-supported
Ruby API for fetching content.

We believe that Contentful is simpler and cheaper than implementing a custom
content management system.

## Decision

We will use Contentful as our content management interface and backend data
storage.

## Consequences

We do not need to maintain a content management interface or manage roles and
permissions.

We rely on a third-party service and their pricing. However, this is mitigated
by the fact that the API allows us to export all the data if we want to
migrate away in the future.
