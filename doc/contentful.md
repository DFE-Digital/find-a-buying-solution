## Exporting and importing Contentful data

It's best to use a separate Contentful space for local development. This avoids making breaking schema changes in a space shared with others.

## Install the CLI
brew install contentful-cli

## login to the DfE FABS account
contentful login 

## Export the FABS space. This will create a JSON file.
contentful space export

## Log out
contentful logout

## login to your own Contentful account
contentful login

## Create a new space
contentful space create

## Import the file exported earlier
contentful space import --content-file EXPORTED_JSON_FILE --space-id SPACE_ID
