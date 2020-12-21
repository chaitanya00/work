node {
try {
eemail('STARTED')
        stage('Workspace Clean')
        {
            deleteDir()
            
        }

        stage('Git Checkout') {
          
                checkout([
	                $class: 'GitSCM', 
	                branches: [[name: '*/master']],  
	                userRemoteConfigs: [[url: 'gitlab project url']]
	                ])          
	           
            }
        
        stage('Code Testing ') {
            withMaven(
                maven: 'maven3.6.3'
                ) {
                         sh "mvn clean test"
            }
      
   }

   stage('Code Dependency verification ') {
       withMaven(
                maven: 'maven3.6.3'
                ) {
                      sh "mvn verify"
                }
        
   }
        
      stage('Maven Clean Install') {
          withMaven(
                maven: 'maven3.6.3'
                ) {
	               sh "mvn clean install"
                }
            
        }
        
        
        stage('Deploying Zip On Author CRXDE') {
	               
                sh 'curl -u username:password -F file=@"'+env.WORKSPACE+'/path/to/your/project/*.zip" -F force=true -F install=true http://aem-author-or-publish-endpoint/crx/packmgr/service.jsp'
                
            
        }
    
}
catch (e) {
  
   currentBuild.result = "FAILED"
   throw e
 } finally {
   
   eemail(currentBuild.result)
 }

}

    def eemail(String buildStatus = 'STARTED') {
 
 buildStatus =  buildStatus ?: 'SUCCESSFUL'


 def subject = "${buildStatus}: Job '${env.JOB_NAME} ${env.BUILD_NUMBER}'"
 def details = """Look for detailed logs at : ${env.BUILD_URL}console"""

 emailext (
     
     subject: subject,
     body: details,
     to: 'email@gmail.com'
     )
}

