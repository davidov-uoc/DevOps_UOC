pipeline {
    agent any

    stages {
        stage('1. Checkout') {
            steps { 
                checkout scm 
            }
        }

        stage('2. Linting (HTML Check)') {
            steps {
                script {
                    def html = "index.html"
                    // Validación de etiquetas <p> abiertas/cerradas y formato
                    def badFormat = sh(script: 'grep -E "<p[^>]*$|<p[^>]*<|</p[^>]*$|</p[^>]*<" index.html', returnStatus: true)
                    def opens = sh(script: "grep -oE '<p[[:space:]>]' ${html} | wc -l", returnStdout: true).trim().toInteger()
                    def closes = sh(script: "grep -oE '</p>' ${html} | wc -l", returnStdout: true).trim().toInteger()

                    if (badFormat == 0 || opens != closes) {
                        error("Fallo de validación en ${html}: Etiquetas <p> mal formadas o no balanceadas.")
                    }
                }
            }
        }

        stage('3. Build & Tag') {
            when { branch 'main' }
            steps {
                script {
                    // Usamos --no-cache para asegurar que el cambio en el index.html se procese siempre
                    sh 'docker build --no-cache -t mi-web-uoc:${BUILD_NUMBER} .'
                    sh 'docker tag mi-web-uoc:${BUILD_NUMBER} mi-web-uoc:latest'
                }
            }
        }

        stage('4. Deploy to Kubernetes (Debug)') {
            when { branch 'main' }
            steps {
                script {
                    sh '''
                    echo "--- 1. ¿Quién soy y qué veo? ---"
                    id
                    ls -la /home/davidov/.minikube/machines/minikube/id_rsa || echo "No puedo ver la llave RSA"

                    echo "--- 2. Probando carga con sudo y rutas explícitas ---"
                    # Intentamos cargar la imagen forzando CUALQUIER ruta posible
                    sudo MINIKUBE_HOME=/home/davidov \
                         MINIKUBE_PROFILE=minikube \
                         minikube image load mi-web-uoc:latest --profile minikube

                    echo "--- 3. Verificando si la imagen entró en Minikube ---"
                    sudo MINIKUBE_HOME=/home/davidov minikube image ls --format table | grep mi-web-uoc || echo "La imagen NO está en Minikube"

                    echo "--- 4. Aplicando y Reiniciando ---"
                    kubectl apply -f deployment.yaml
                    kubectl rollout restart deployment mi-web-uoc
                    
                    echo "--- 5. ¿Qué ID de imagen tiene el Pod ahora? ---"
                    kubectl get pod -l app=web-uoc -o jsonpath='{.items[0].status.containerStatuses[0].imageID}'
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Build y despliegue completado con éxito.'
        }
        failure {
            echo 'El Pipeline ha fallado. Revisa los logs superiores.'
        }
    }
}
