pipeline {
  agent none
  stages {
    stage('run') {
      agent { dockerfile true }
      steps {
        sh 'make all'
      }
    }
  }
}
