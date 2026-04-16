pipeline {
    agent any
    stages {
        stage('1. Checkout') {
            steps {
                checkout scm
            }
        }
        stage('2. Linting (Check HTML)') {
            steps {
                echo 'Validando el código HTML...'
                // Si quieres que falle de verdad, aquí instalaríamos 'tidy' 
                // Por ahora, simulamos el chequeo con un script simple
                sh 'grep -q "</p>" index.html || (echo "ERROR: Etiqueta p no cerrada" && exit 1)'
            }
        }
        stage('3. Build Docker Image') {
            steps {
                sh 'docker build -t mi-web-uoc:${BUILD_NUMBER} .'
                sh 'docker tag mi-web-uoc:${BUILD_NUMBER} mi-web-uoc:latest'
            }
        }
        stage('4. Deploy to Minikube') {
            steps {
                echo 'Desplegando en Kubernetes...'
                // Aquí iría el comando kubectl si Minikube está corriendo
                sh 'minikube status && kubectl apply -f deployment.yaml || echo "Minikube no disponible"'
            }
        }
    }
}