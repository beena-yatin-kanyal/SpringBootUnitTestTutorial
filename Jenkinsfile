//scripted jenkins file
node('master') {
    try {
		def app

        properties([
            buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '30', numToKeepStr: '15')),
            disableConcurrentBuilds()
        ])

		// some parameter based testing
		if ("${env.BRANCH_NAME}" == "master" || "${env.BRANCH_NAME}" == "develop"') {
            properties([
                    parameters([
                            booleanParam(name: 'deploy', defaultValue: false, description: 'Check box for creating docker image'),
                            booleanParam(name: 'execute_Vulnerability', defaultValue: true, description: 'Do you want to run the vulnerability step?')
                    ])
            ])
        }

        stage("Checkout") {
			stageName = "${env.STAGE_NAME}"
            echo "Checking out the project"
            try {
                checkout scm
            } catch (Exception e) {
                throw e
            }
        }

        stage("Running testcases") {
			stageName = "${env.STAGE_NAME}"
            echo "Running the testcases"
            sh "mvn test"
        }

        stage("Bundling project") {
			stageName = "${env.STAGE_NAME}"
            echo "Bundling the project"
            sh "mvn clean install -Pall-integration"
        }

        stage("Deploying to nexus") {
			stageName = "${env.STAGE_NAME}"
            echo "Deploying the bundled jar to the nexus"
			// sh "mvn clean deploy -Pall-integration"
        }

        stage("Sonar analyzer") {
			stageName = "${env.STAGE_NAME}"
            echo "Running sonar analyzer"
			// ${branchName} represents the current branch from where you're working
			// or code is being pulled
			// sh "mvn sonar:sonar -Dsonar.branch.name=${branchName} -Dsonar.branch.target=master"
        }

        stage("Running vulnerability check") {
			stageName = "${env.STAGE_NAME}"
			if (params.execute_Vulnerability) {
				echo "Running the vulnerability step"

				// use below command to run suppressions with suppressions.xml file
				// sh "mvn dependency-check:aggregate -DsuppressionFile.path=suppressions.xml"

				// use below command to run suppressions without suppressions.xml file
				// sh "mvn dependency-check:aggregate"
			} else echo "Skipping the vulnerability step."
        }

        stage("Building Docker image") {
			stageName = "${env.STAGE_NAME}"
            echo "Performing docker setup"
			try {
                dir("${Directory}") {
					// this builds the actual image; synonymous to
					// docker build on the command line
                    app = docker.build("getintodevops/hellonode")
                }
            } catch (Exception e) {
                throw e
            }
        }

        stage("Tag and publish to hub") {
			stageName = "${env.STAGE_NAME}"
            echo "Tagging the docker image and pushing it to the hub"
			// we'll push the image with two tags:
			// first, the incremental build number from Jenkins
			// second, the 'latest' tag
			// note - configure "docker-hub-credentials" in the jenkins
			// reference link - Credentials -> System -> Global credentials -> Add Credentials
			docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
				app.push("${env.BUILD_NUMBER}")
				app.push("latest")
			}
        }

        stage("Removing local image") {
			stageName = "${env.STAGE_NAME}"
            echo "Clearing the work directory"
			try {
                sh "docker rmi -f $(docker images -a -q)"
            } catch (Exception e) {
                throw e
            }
        }

        stage("Performing deployment") {
			stageName = "${env.STAGE_NAME}"
            echo "Performing the deployment"
			if (params.deploy) {
				echo "Starting deployment"
			} else echo "Skipping deployment"
        }

        stage("Wipe out directory") {
			stageName = "${env.STAGE_NAME}"
			echo "Wiping out the working directory"
            sh "sudo rm -rf $WORKSPACE/*"
            deleteDir()
        }

        stage("Post action") {
			stageName = "${env.STAGE_NAME}"
            echo "Performing the post action step. Setup email or slack notifications"
        }
    }
    catch (Exception e) {
        throw e
    }
}
