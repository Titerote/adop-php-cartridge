node {
  sh 'echo test'
  stage('Example') {
    input "ready or not ?"
  }
}
