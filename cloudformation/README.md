## Creating a new stack
1. Copy `.env-sample` to `.env`
2. Adjust relevant and required cloudformation variables
3. Run `./deploy.sh`

## Updating existing stack
1. Fetch the `.env` file for the deployment. Check with the team where to find this. It could be on 1Password, or on S3.
2. Run `./deploy.sh`