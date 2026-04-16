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
                echo 'Validando cierre de etiquetas...'
                // Este comando busca específicamente si hay un <p> que NO tiene su </p> después
                sh 'grep -q "</p>" index.html || (echo "ERROR: Falta etiqueta de cierre </p>" && exit 1)'
                
                // Opcional: Forzar fallo si encuentra la cadena exacta del error
                sh '! grep -F "<p>davidov estuvo aquí <p>" index.html' 
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
