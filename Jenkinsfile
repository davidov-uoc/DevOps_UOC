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
                    # 1. Cargamos la imagen CON EL NÚMERO DE BUILD (ID único, esto no se puede cachear)
                    sudo MINIKUBE_HOME=/home/davidov minikube image load mi-web-uoc:${BUILD_NUMBER}
                    
                    # 2. Actualizamos el deployment.yaml al vuelo para que use la imagen con el número de build
                    sed -i "s|image: mi-web-uoc:latest|image: mi-web-uoc:${BUILD_NUMBER}|g" deployment.yaml
                    
                    # 3. Aplicamos el cambio
                    kubectl apply -f deployment.yaml
                    
                    # 4. Forzamos el reinicio (aunque al cambiar el nombre de la imagen, K8s lo hará solo)
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
