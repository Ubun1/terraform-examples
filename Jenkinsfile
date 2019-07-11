pipeline {
  agent none
  stages {
    stage('') {
      agent {
        docker {
          image 'golang:1.12'
        }

      }
      steps {
        sh 'make all'
      }
    }
  }
}