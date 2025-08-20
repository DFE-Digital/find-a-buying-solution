# Find A Buying Solution
[Github Repo](https://github.com/DFE-Digital/find-a-buying-solution)

A service to help school buying professionals create an end-to-end seamless journey (service) that helps users in schools to find, choose and use the right buying solution for them.

## Getting Started with Development

Read [Setting up a development environment](doc/developer-setup.md) to learn
how to configure your local environment and get access to required systems.

### Docker

We will use docker locally to run elastic search, so need to install docker.

Install Docker: [https://docs.docker.com/desktop/mac/install/](https://docs.docker.com/desktop/mac/install/)

This Docker for Desktop Mac install will be the easiest way to run it and it comes with both `docker` and `docker compose` shell commands.

Then you need to run `docker compose up`


Create elasticsearch api key using this command
```
curl -X POST "http://localhost:9200/_security/api_key" -H "Content-Type: application/json" -u elastic:FMp3U3uVm6PG-tLE4p5y -d'
{
  "name": "full_privileges_api_key",
  "role_descriptors": {
    "full_access": {
      "cluster": ["all"],
      "index": [
        {
          "names": ["*"],
          "privileges": ["all"]
        }
      ]
    }
  }
}
'
```
The encoded field contains the full Base64-encoded API key. This is the value needs to be save in ELASTICSEARCH_API_KEY environment variable
```
{
  "id":"id",
  "name":"elasticsearch_api_key",
  "api_key":"api_key",
  "encoded":"encoded_key"
}
```
