Roames Github Repositories Crawler
==================================

This Docker container clone a list of open source repositories from github and compile a list of all commits made by users with a Roames email address.

Building the container
----------------------

From the current directory run the following command:

    docker build -t "git_crawler" .


Crawl repositories
------------------

### Input

When running, the container grabs the list of repositories to crawl from a json file with the following format

    [
      {
        "label": "displaz",
        "full_name": "c42f/displaz"
      },
      {
        "label": "conda",
        "full_name": "conda/conda"
      }
    ]

The list of repositories can be passed to the container at runtime using environment variables:

- if you want the container to download the json file from a location on the web set the `REPO_LIST_URL` environment variable to the URL of the json file
- if you want the container to load the list from a local json file set the `REPO_LIST_PATH` environment variable and remember to bind the file inside the container using the docker volumne `-v` option.

### Output

The output of the crawler is a json file with a list of commits made by users with Roames email for each repository passed in. An example output looks like the following

    [
      {
        "email": "jacopo.sabbatini@roames.com.au",
        "date": "2015-01-19T11:56:52+10:00",
        "name": "Jacopo",
        "files": 1,
        "insertions": 4,
        "deletions": 4
      },
      {
        "email": "jacopo.sabbatini@roames.com.au",
        "date": "2014-09-23T08:42:16+10:00",
        "name": "Jacopo",
        "files": 1,
        "insertions": 2,
        "deletions": 2
      }
    ]

The crawler will write the resulting json files on a location in S3 as public files or on a local path:

- if you want the crawler to output the json files to S3 set the environment variable `RESULTS_S3_PATH` to an S3 path where the files will be written. Remember to also set the AWS credentials `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as environment variables
- if you want the crawler to write the results to a local path set the environment variable `RESULTS_LOCAL_PATH` to the path you want the files in. Don't forget to bind the output folder using the `-v` option when running the container.

## Examples

The command:

    docker run -e REPO_LIST_URL=http://localhost:8000/repo_list.json -e RESULTS_S3_PATH=s3://some-bucket/crawler/ -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY git_crawler

will load the repository list from the URL `https://localhost:8000/repo_list.json` and write the results onto the S3 path `s3://some-bucket/crawler/` while using the AWS credentials from the current running environment.

The command

    docker run -v /some/local/path/:/repo/ -e REPO_LIST_PATH=/repo/repo_list.json -e RESULTS_LOCAL_PATH=/repo/ git_crawler

will load the repository list from the file `repo_list.json` located in the local path `/some/local/path/` (bound to the directory `/repo` inside the container) and will write the resulting json files in the same directory.
