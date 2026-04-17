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
                echo 'Validando sintaxis HTML...'
                script {
                    def validationFailed = false
                    def errorMsg = ""
                    
                    // Validar que NO haya etiquetas <p sin cerrar >
                    def openTagCheck = sh(
                        script: '''
                            # Buscar <p que no termine en > antes del siguiente 
                            if grep -E '<p[^>]*<' index.html; then
                                exit 1
                            fi
                            # Buscar <p al final de línea sin >
                            if grep -E '<p[^>]*$' index.html; then
                                exit 1
                            fi
                            exit 0
                        ''',
                        returnStatus: true
                    )
                    
                    // Validar que NO haya etiquetas </p sin cerrar >
                    def closeTagCheck = sh(
                        script: '''
                            # Buscar </p que no termine en > antes del siguiente 
                            if grep -E '</p[^>]*<' index.html; then
                                exit 1
                            fi
                            # Buscar </p al final de línea sin >
                            if grep -E '</p[^>]*$' index.html; then
                                exit 1
                            fi
                            exit 0
                        ''',
                        returnStatus: true
                    )
                    
                    // Contar etiquetas bien formadas
                    def tagBalance = sh(
                        script: '''
                            OPEN=$(grep -oE '<p[[:space:]>]' index.html | wc -l)
                            CLOSE=$(grep -oE '</p>' index.html | wc -l)
                            
                            echo "Etiquetas <p> abiertas: $OPEN"
                            echo "Etiquetas </p> cerradas: $CLOSE"
                            
                            if [ "$OPEN" -ne "$CLOSE" ]; then
                                exit 1
                            fi
                            exit 0
                        ''',
                        returnStatus: true
                    )
                    
                    // Evaluar resultados
                    if (openTagCheck != 0) {
                        errorMsg += "❌ ERROR: Etiqueta <p> mal formada (falta '>')\n"
                        validationFailed = true
                    }
                    
                    if (closeTagCheck != 0) {
                        errorMsg += "❌ ERROR: Etiqueta </p> mal formada (falta '>')\n"
                        validationFailed = true
                    }
                    
                    if (tagBalance != 0) {
                        errorMsg += "❌ ERROR: Número de etiquetas <p> y </p> no coincide\n"
                        validationFailed = true
                    }
                    
                    if (validationFailed) {
                        echo errorMsg
                        sh '''
                            echo "════════════════════════════════════"
                            echo "CONTENIDO DE index.html:"
                            echo "════════════════════════════════════"
                            cat index.html
                            echo "════════════════════════════════════"
                        '''
                        error("❌ Validación HTML FALLIDA - Corrige los errores antes de hacer merge")
                    } else {
                        echo "✅ HTML validado correctamente"
                    }
                }
            }
        }
        
        stage('3. Build Docker Image') {
            when {
                branch 'main'
            }
            steps {
                echo 'Construyendo imagen Docker...'
                sh 'docker build -t mi-web-uoc:${BUILD_NUMBER} .'
                sh 'docker tag mi-web-uoc:${BUILD_NUMBER} mi-web-uoc:latest'
            }
        }
        
        stage('4. Deploy to Minikube') {
            when {
                branch 'main'
            }
            steps {
                echo 'Desplegando en Kubernetes...'
                sh '''
                    if minikube status; then
                        kubectl set image deployment/mi-web-uoc mi-web-uoc=mi-web-uoc:${BUILD_NUMBER}
                    else
                        echo "Minikube no disponible - saltando deploy"
                    fi
                '''
            }
        }
    }
    
    post {
        failure {
            echo '🚨 BUILD FALLIDO - NO SE PUEDE HACER MERGE A MAIN'
            echo 'Revisa los errores de validación HTML arriba'
        }
        success {
            echo '✅ Pipeline completado - código validado correctamente'
        }
    }
}
