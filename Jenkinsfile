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
                    # 1. Verificar que todas las etiquetas <p> tengan su cierre >
                    if grep -E "<p[^>]*$" index.html; then
                        echo "❌ ERROR: Etiqueta <p sin cerrar correctamente"
                        exit 1
                    fi
                    
                    # 2. Verificar que todas las etiquetas </p> terminen en >
                    if grep -E "</p[^>]*$" index.html; then
                        echo "❌ ERROR: Etiqueta </p sin cerrar correctamente"
                        exit 1
                    fi
                    
                    # 3. Contar etiquetas abiertas y cerradas (solo completas)
                    TOTAL_OPEN=$(grep -oE "<p[ >]" index.html | wc -l)
                    TOTAL_CLOSE=$(grep -oE "</p>" index.html | wc -l)
                    
                    if [ "$TOTAL_OPEN" -ne "$TOTAL_CLOSE" ]; then
                        echo "❌ ERROR: Etiquetas <p> desbalanceadas"
                        echo "Abiertas: $TOTAL_OPEN | Cerradas: $TOTAL_CLOSE"
                        exit 1
                    fi
                    
                    echo "✅ HTML validado correctamente"
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
