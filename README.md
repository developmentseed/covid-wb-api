# covid-wb-api
COVID-19 Risk Schema API for the World Bank

# CI
CircleCI builds a new image and tags it with `latest`, branch name and the unique build number. This is pushed to AWS ECR for this project. For deploying, see cloudformation/README.md.