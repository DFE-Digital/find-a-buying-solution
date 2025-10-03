# Find A Buying Solution
[Github Repo](https://github.com/DFE-Digital/find-a-buying-solution)

A service to help school buying professionals create an end-to-end seamless journey (service) that helps users in schools to find, choose and use the right buying solution for them.

## Getting Started with Development

Read [Setting up a development environment](doc/developer-setup.md) to learn
how to configure your local environment and get access to required systems.

### Docker

We will use docker locally to run OpenSearch.

Install Docker: [https://docs.docker.com/desktop/mac/install/](https://docs.docker.com/desktop/mac/install/)

This Docker for Desktop Mac install will be the easiest way to run it and it comes with both `docker` and `docker compose` shell commands.

Then you need to run `docker compose up`

To use the local search index, set `OPENSEARCH_URL` to
`http://admin:PASSWORD@localhost:9200` where `PASSWORD` is as specified in the
compose file.

Contentful webhook in local development

To recvice  contentful webhook,  you need will need to install `ngrok` to expose your local rails server

```
brew install ngrok

create a free account on with ngrok https://dashboard.ngrok.com/signup
copy auth toke
ngrok config add-authtoken {token}

ngrok http http://localhost:3000
```

You should get a screen like this
```
ngrok                                                                            (Ctrl+C to quit)

🧱 Block threats before they reach your services with new WAF actions → https://ngrok.com/r/waf

Session Status                online
Account                       test@example.com (Plan: Free)
Version                       3.26.0
Region                        Europe (eu)
Latency                       23ms
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://e1507fc863f0.ngrok-free.app -> http://localhost:3000

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

You will need to save the forwarding url in `CONTENTFUL_WEBHOOK_HOST` environment variable.

Now take the forwarding url and create a web hook in contentful like

https://app.contentful.com/spaces/xdhmps7ck0lp/settings/webhooks/3abewvVCTpeftGHoSfY5U1/settings

