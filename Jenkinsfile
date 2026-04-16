pipeline {
    agent any
    stages {
        stage('1. Checkout') {
            steps {
                checkout scm
            }
        }
        stage('2. Linting (Validar HTML)') {
            steps {
                echo 'Analizando el código del alumno...'
                sh '''
                    # Contamos cuántas etiquetas se abren y cuántas se cierran
                    OPENS=$(grep -o "<p>" index.html | wc -l)
                    CLOSES=$(grep -o "</p>" index.html | wc -l)
                    
                    echo "Etiquetas abiertas: $OPENS"
                    echo "Etiquetas cerradas: $CLOSES"
                    
                    if [ "$OPENS" -ne "$CLOSES" ]; then
                        echo "------------------------------------------------------"
                        echo "ERROR: ¡Sintaxis HTML incorrecta detectada!"
                        echo "Has dejado etiquetas <p> sin cerrar con </p>."
                        echo "------------------------------------------------------"
                        exit 1
                    else
                        echo "Felicidades: Todo parece estar bien cerrado."
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
