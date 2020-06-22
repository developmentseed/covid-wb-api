# covid-wb-api
COVID-19 Risk Schema API for the World Bank

## Running locally
* [Setup docker](https://www.docker.com/get-started)
* Clone this repo `git clone https://github.com/developmentseed/covid-wb-api.git`
* Build docker image `docker build -t covid-wb-api .`
* Run `docker run -p 8080:80 --env DNSName='//localhost:8080' covid-wb-api`

## CI
CircleCI builds a new image and tags it with `latest`, branch name and the unique circle build number. This is pushed to AWS ECR for this project. For deploying, see cloudformation/README.md.