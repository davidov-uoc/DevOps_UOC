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

        stage('4. Deploy to Kubernetes') {
            when { branch 'main' }
            steps {
                script {
                    sh '''
                    # Forzamos a sudo a mirar en la carpeta de davidov para encontrar las llaves RSA
                    sudo MINIKUBE_HOME=/home/davidov minikube image load mi-web-uoc:latest
                    
                    # Aplicamos los cambios con kubectl (que ya vimos que Jenkins sí llega)
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                    
                    # Forzamos el reinicio
                    kubectl rollout restart deployment mi-web-uoc
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
