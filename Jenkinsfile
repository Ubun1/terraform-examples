pipeline {
  agent none
  stages {
    stage('run') {
      agent {
        docker {
          dockerfile true
        }
      }
      steps {
        sh 'make all'
      }
    }
  }
}
