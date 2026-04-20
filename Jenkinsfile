pipeline {
    agent any
    
    stages {
        stage('1. Checkout') {
            steps { checkout scm }
        }
        
        stage('2. Linting (HTML Check)') {
            steps {
                script {
                    def html = "index.html"
                    def badFormat = sh(script: "grep -E '<p[^>]*\$|<p[^>]*<|</p[^>]*\$|</p[^>]*<' ${html}", returnStatus: true)
                    def opens = sh(script: "grep -oE '<p[[:space:]>]' ${html} | wc -l", returnStdout: true).trim().toInteger()
                    def closes = sh(script: "grep -oE '</p>' ${html} | wc -l", returnStdout: true).trim().toInteger()

                    if (badFormat == 0 || opens != closes) {
                        error("Fallo de validacion en ${html}")
                    }
                }
            }
        }
        
        stage('3. Build & Tag') {
            when { branch 'main' }
            steps {
                script {
                    sh "docker build -t mi-web-uoc:${BUILD_NUMBER} ."
                    sh "docker tag mi-web-uoc:${BUILD_NUMBER} mi-web-uoc:latest"
                }
            }
        }
    }
    
    post {
        success { echo 'Despliegue en Kubernetes completado.' }
    }
}
