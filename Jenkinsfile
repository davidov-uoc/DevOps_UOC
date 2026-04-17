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
                    // 1. Verificar etiquetas mal formadas (falta el '>')
                    def badFormat = sh(script: "grep -E '<p[^>]*\$|<p[^>]*<|</p[^>]*\$|</p[^>]*<' ${html}", returnStatus: true)
                    
                    // 2. Contar balance de etiquetas
                    def opens = sh(script: "grep -oE '<p[[:space:]>]' ${html} | wc -l", returnStdout: true).trim().toInteger()
                    def closes = sh(script: "grep -oE '</p>' ${html} | wc -l", returnStdout: true).trim().toInteger()

                    if (badFormat == 0 || opens != closes) {
                        sh "echo '--- ERROR: Estructura HTML invalida ---'; cat ${html}"
                        error("Fallo de validacion: Revisa las etiquetas <p> en ${html}")
                    } else {
                        echo "HTML validado: ${opens} etiquetas correctamente cerradas."
                    }
                }
            }
        }
        
        stage('3. Build & Deploy') {
            when { branch 'main' }
            steps {
                script {
                    // Construimos la imagen con el número de build
                    sh "docker build -t mi-web-uoc:${BUILD_NUMBER} ."
                    // Ponemos la etiqueta 'latest' apuntando al nuevo build
                    sh "docker tag mi-web-uoc:${BUILD_NUMBER} mi-web-uoc:latest"
                    
                    echo "Imagen mi-web-uoc:${BUILD_NUMBER} creada y etiquetada como latest."
                }
            }
        }
    }
    
    post {
        failure { echo 'Build fallido: El codigo no cumple los requisitos de calidad.' }
        success { echo 'Build exitoso: Codigo validado.' }
    }
}
