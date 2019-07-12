pipeline {
  agent none
    stages {
    stage('terraform validate') {
      agent { docker 
        { 
          image 'hashicorp/terraform:0.11.14'
          args '-v $(pwd):/root/proj'
        }
      }
      steps { sh 'cd /root/proj && make lint-terraform' }
    }
    stage('rstcheck') {
      agent { docker 
        { 
          image 'python3'
          args '-v $(pwd):/root/proj'
        }
      }
      steps { sh 'cd /root/proj && make lit-rst' }
    }
  }
}
