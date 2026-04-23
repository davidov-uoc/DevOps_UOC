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
                    def badFormat = sh(script: 'grep -E "<p[^>]*$|<p[^>]*<|</p[^>]*$|</p[^>]*<" index.html', returnStatus: true)
                    def opens = sh(script: "grep -oE '<p[[:space:]>]' ${html} | wc -l", returnStdout: true).trim().toInteger()
                    def closes = sh(script: "grep -oE '</p>' ${html} | wc -l", returnStdout: true).trim().toInteger()

                    if (badFormat == 0 || opens != closes) {
                        error("Fallo de validacion en ${html}")
                    }
                }
            }
        }
        stage('Debug Entorno') {
            steps {
                script {
                    sh '''
                    echo "--- Entorno de Jenkins ---"
                    env | grep -E "DOCKER|KUBECONFIG|MINIKUBE" || echo "No hay variables de entorno Docker/Kube"
                    
                    echo "--- Identidad y Rutas ---"
                    id
                    which docker
                    which kubectl
                    
                    echo "--- Contexto de Kubernetes ---"
                    kubectl config current-context
                    kubectl config view --minify
                    
                    echo "--- Estado de Minikube ---"
                    minikube status || echo "Minikube no accesible para Jenkins"
                    '''
                }
            }
        }
        stage('3. Build & Tag') {
            when { branch 'main' }
            steps {
                script {
                    // Esto asegura que Docker no use NADA del pasado
                    sh 'docker system prune -f'
                    // Añadimos --no-cache para que Docker no use versiones viejas del HTML
                    sh 'docker build --no-cache -t mi-web-uoc:${BUILD_NUMBER} .'
                    sh 'docker tag mi-web-uoc:${BUILD_NUMBER} mi-web-uoc:latest'
                }
            }
        }

        stage('4. Deploy to Kubernetes') {
            when { branch 'main' }
            steps {
                script {
                    sh '''

                    export MINIKUBE_HOME=/var/lib/jenkins
                    minikube image load mi-web-uoc:latest
                    kubectl rollout restart deployment mi-web-uoc
                    # 1. Forzamos el borrado en Minikube para que no ignore la carga
                    minikube image rm mi-web-uoc:latest || true
                    
                    # 2. Cargamos la imagen fresca
                    minikube image load mi-web-uoc:latest
                    
                    # 3. Aplicamos el deployment (el archivo para los pods)
                    kubectl apply -f deployment.yaml
                    
                    # 4. Aplicamos el service (el archivo para el balanceo)
                    kubectl apply -f service.yaml
                    
                    # 5. Reiniciamos el deployment correcto para forzar la actualización
                    kubectl rollout restart deployment mi-web-uoc
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Build y despliegue (solo Deployment) completado.'
        }
    }
}
