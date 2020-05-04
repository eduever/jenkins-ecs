def BuildBadge = addEmbeddableBadgeConfiguration(id: "build", subject: "nuild")

pipeline {
    agent { docker { image 'zenika/terraform-aws-cli' } }
    stages {
        stage ('checkout code') {
            steps {
                git(url: 'https://github.com/eduever/jenkins-ecs.git', branch: "master", credentialsId: 'eduever')
            }
        }
        stage ('build the docker') {
            steps {
                dir("app") {
                    script {
                        BuildBadge.setStatus('running')
                        try {
                            sh '''
                            ls -la
                            aws --version
                            aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 175546642044.dkr.ecr.us-east-1.amazonaws.com/myapp-ecr-repo
                            docker build -t myapp-ecr-repo .
                            docker tag myapp-ecr-repo 175546642044.dkr.ecr.us-east-1.amazonaws.com/myapp-ecr-repo
                            docker push 175546642044.dkr.ecr.us-east-1.amazonaws.com/myapp-ecr-repo
                            '''
                            RunBuild()
                            BuildBadge.setStatus('passing')
                        } 
                        catch (Exception err) {
                            BuildBadge.setStatus('failing')
                            error 'Build failed'
                        }
                    }
                }
            }
          
        }
        stage ('update ECS task') {
            steps {
                sh '''
                aws ecs register-task-definition --family myapp-task --network-mode awsvpc --requires-compatibilities FARGATE --execution-role-arn arn:aws:iam::175546642044:role/myEcsTaskExecutionRole --cpu 1024 --memory 2048 --cli-input-json file://./task-definition.json
                aws ecs update-service --cluster myapp-cluster --service myapp-service --task-definition myapp-task --force-new-deployment
                '''
            }
        }
    }
}