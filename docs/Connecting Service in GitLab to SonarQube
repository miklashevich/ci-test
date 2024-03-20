# Connecting Service in GitLab to SonarQube

To integrate SonarQube analysis into your GitLab CI/CD pipeline, follow these steps:

## Prerequisites

- Ensure that your project codebase is compatible with SonarQube analysis. SonarQube supports various programming languages and frameworks, but you should verify compatibility before proceeding.
- Make sure you have the necessary permissions to configure GitLab CI/CD and access SonarQube.

## Step 1: Set Up SonarQube Server

1. Log in to your SonarQube instance (open http://sonarqube.miklashevich.online). 
2. Create a new project or select the existing project where your Golang service resides.
3. In the project settings, ensure the "Golang" language is enabled for analysis.
4. Generate token using sonarqube UI

## Step 2: Configure GitLab CI/CD Pipeline

1. In your GitLab repository, create or modify the `.gitlab-ci.yml` file to include SonarQube analysis in your pipeline.

 Here's an example:

```yaml
sonarqube-check:
  stage: sonarqube-check
  image: 
    name: sonarsource/sonar-scanner-cli:5.0
    entrypoint: [""]
  variables:
    SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"  # Defines the location of the analysis task cache
    GIT_DEPTH: "0"  # Tells git to fetch all the branches of the project, required by the analysis task
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script: 
    - sonar-scanner
  allow_failure: true
  only:
    - main
    
```
2. Create a [sonar-project.properties] file in your repository.
 Here's an example:

```
sonar.projectKey=miklashevich.a_service_35749ea6-38a4-4cf7-9304-790b62824ede
sonar.qualitygate.wait=true

```
## Step 3: Run the Pipeline
1. Trigger the pipeline by pushing new changes to your repository or manually starting the pipeline in the GitLab UI.
2. Monitor the pipeline execution to ensure that the SonarQube analysis step runs successfully.
3. Once the pipeline completes, navigate to your SonarQube dashboard to view the analysis results and identify any code quality issues or vulnerabilities.

Note: that this is a minimal base configuration to run a SonarQube analysis on your main branch and merge requests, and fetch the vulnerability report (if applicable)
