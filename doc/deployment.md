# Deployment

Deployment is handled automatically using a Heroku pipeline.

## Pull requests

A review app is created automatically for each pull request. This is
deployed whenever a push passes the CI checks.

Review apps are automatically deleted after a day of inactivity.

## Staging

Every push to `main` is automatically deployed to staging.

## Production

A build can be promoted from staging to production using the "Promote to
production" button in the Heroku pipeline.
