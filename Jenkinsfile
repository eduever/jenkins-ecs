def BuildBadge = addEmbeddableBadgeConfiguration(id: "build", subject: "nuild")

pipeline {
    agent { docker { image 'node:7-alpine' } }
    stages {
        steps {
            script {
                BuildBadge.setStatus('running')
                try {
                    RunBuild()
                    BuildBadge.setStatus('passing')
                } catch (Exception err) {
                    BuildBadge.setStatus('failing')
                    error 'Build failed'
                }
            }
        }
    }
}