# covid-wb-api
COVID-19 Risk Schema API for the World Bank

## Running locally
* [Setup docker](https://www.docker.com/get-started)
* Clone this repo `git clone https://github.com/developmentseed/covid-wb-api.git`
* Build docker image `docker build -t covid-wb-api .`
* Create a new environment by copying `.env-sample` and add the right PostgreSQL variables
* Run `docker run --env-file ./.env -p 8080:80 covid-wb-api`
* Now visit http://localhost:8080 to see the API

## CI
CircleCI builds a new image and tags it with `latest`, branch name and the unique circle build number. This is pushed to AWS ECR for this project. For deploying, see cloudformation/README.md.