# Contentful Environment Promotion

This document describes how we manage Contentful environments and the promotion process from staging to production.

## Environment Structure

We maintain these environments in Contentful:
- `staging` - Used for all live changes. This is where content is edited, reviewed, approved and published.
- `production-YYYY-MM-DD-HHMM` - For the production servers only. Only to be used for pushing new content live on production as per the process described below, not for directly editing.

We also use environment aliases to point to the active environments:
- `production` alias points to the current production environment
- `master` alias points to the `staging` environment

NOTE: `master` used to be an environment ID (not alias) but while trying to create an alias in the Contentful UI, the `master` alias got created by mistake. There is no way to undo this in Contentful.

## Promotion Process

Contentful does not provide a native way to "promote" content from one environment to another. The only way is to clone the environment we want to promote and then point the `production` alias to the new cloned environment.

Our Contentful plan is limited to 3 environments and 3 aliases.

So, this is the approach we're using:

1. Clone a new environment from `master` (`staging`). Name it `production-YYYY-MM-DD-HHMM` to capture the timestamp of when it was created.

2. Point the `production` alias to the new environment.

3. Delete the old production environment.

## Running the task on Heroku

Make sure the `CONTENTFUL_SPACE_ID` and `CONTENTFUL_CMA_TOKEN` environment variables are set in Heroku. Then run:

```bash
heroku run rake contentful:promote -a fabs-prod
```
