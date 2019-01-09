stage('Example') {
  node {
    sh 'echo test'
  }
  input "ready or not ?"
}
