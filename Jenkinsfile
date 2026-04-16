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
                // 1. Verificamos que al menos exista un cierre de etiqueta </p>
                sh 'grep -q "</p>" index.html'
                
                echo 'Buscando errores de sintaxis específicos...'
                // 2. Si encuentra la etiqueta mal abierta "<p>" sin el ">", el pipeline SE PARA.
                // Usamos un if simple que es más estable en Jenkins
                sh '''
                    if grep -q "<p>davidov estuvo aquí <p>" index.html; then
                        echo "ERROR: Se ha detectado una etiqueta mal cerrada en la aportación de Davidov."
                        exit 1
                    fi
                '''
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
