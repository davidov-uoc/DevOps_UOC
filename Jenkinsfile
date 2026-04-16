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
                echo 'Validando integridad del HTML...'
                sh '''
                    # Contamos cuántas veces aparece <p y cuántas </p
                    TOTAL_OPEN=$(grep -o "<p" index.html | wc -l)
                    TOTAL_CLOSE=$(grep -o "</p" index.html | wc -l)
        
                    if [ "$TOTAL_OPEN" -ne "$TOTAL_CLOSE" ]; then
                        echo "ERROR DE VALIDACIÓN: Etiquetas mal cerradas."
                        echo "Abiertas: $TOTAL_OPEN | Cerradas: $TOTAL_CLOSE"
                        exit 1
                    else
                        echo "HTML validado correctamente."
                    fi
                '''
            }
        }
        stage('3. Docker Build') {
            steps {
                echo 'Construyendo la imagen Docker...'
                sh 'docker build -t mi-web-uoc:${BRANCH_NAME} .'
            }
        }
    }
}
