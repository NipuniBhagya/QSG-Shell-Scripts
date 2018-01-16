#!/bin/sh

# ----------------------------------------------------------------------------
#  Copyright 2017 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

configure_sso_saml2 () {

# Check whether the wso2-is and tomcat servers exits and if they don't download and install them.
setup_servers

# Add users in the wso2-is.
add_user admin admin 2

# Add service providers in the wso2-is 
add_service_provider dispatch 2 urn:createApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz
add_service_provider swift 2 urn:createApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz

# Configure SAML for the service providers   
configure_saml dispatch 2 urn:addRPServiceProvider https://localhost:9443/services/IdentitySAMLSSOConfigService.IdentitySAMLSSOConfigServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz
configure_saml swift 2 urn:addRPServiceProvider https://localhost:9443/services/IdentitySAMLSSOConfigService.IdentitySAMLSSOConfigServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz

create_updateapp_xml dispatch Y2FtZXJvbjpjYW1lcm9uMTIz
create_updateapp_xml swift Y2FtZXJvbjpjYW1lcm9uMTIz	
	
update_application dispatch 2 urn:updateApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz
update_application swift 2 urn:updateApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz

echo
echo "------------------------------------------------------------------"
echo "|                                                                |"
echo "|  You can find the sample web apps on the following URLs.       |"
echo "|  *** Please press ctrl button and click on the links ***       |"              
echo "|                                                                |"
echo "|  Dispatch - http://localhost:8080/saml2-web-app-dispatch.com/  |"  
echo "|  Swift - http://localhost:8080/saml2-web-app-swift.com/        |" 
echo "|                                                                |"  
echo "------------------------------------------------------------------"
echo
echo "If you have finished trying out the sample web apps, you can clean the process now."
echo "Do you want to clean up Setup-02?"
echo
echo "Press y - YES"
echo "Press n - NO"
echo
read clean

 case ${clean} in
        [Yy]* ) 
	delete_sp dispatch 2 urn:deleteApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/
        delete_sp swift 2 urn:deleteApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/
        delete_user
	break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
return 0;
}

setup_servers() {
cd ..
cd ..
cd ..
echo "Please enter the path to your WSO2-IS pack."
echo "Example: /home/downloads/WSO2_Products/wso2is-5.4.0"
read WSO2_HOME
echo 
echo "Please enter the path to your Tomcat server pack."
echo "Example: /home/downloads/apache-tomcat-7.0.82"
read TOMCAT_HOME
echo
echo "Please enter the path to your Quick Start Guide bundle."
echo "Example: /home/downloads/QSG-bundle"
read QSG
echo 

 if [ ! -d "${WSO2_HOME}" ]
  then
    echo "${WSO2_HOME} Directory does not exists. Please download and install the latest pack."
    return -1
 fi

 if [ ! -d "${TOMCAT_HOME}" ]
  then
    echo "${TOMCAT_HOME} Directory does not exists. Downloading apache-tomcat-7.0.82..."
    wget http://www-eu.apache.org/dist/tomcat/tomcat-7/v7.0.82/bin/apache-tomcat-7.0.82.tar.gz
    tar xvzf apache-tomcat-7.0.82.tar.gz
    cd binaries
    cp saml2-web-app-dispatch.com.war ${QSG}/apache-tomcat-7.0.82/webapps
    echo "** Web application Dispatch successfully deployed. **" 
    cp saml2-web-app-swift.com.war ${QSG}/apache-tomcat-7.0.82/webapps
    echo "** Web application Swift successfully deployed. **" 
 fi

 if [ ! -f "${TOMCAT_HOME}/webapps/saml2-web-app-dispatch.com.war" ]
  then 
   cd binaries
   cp saml2-web-app-dispatch.com.war ${TOMCAT_HOME}/webapps
   echo "** Web application Dispatch successfully deployed. **"
   cp saml2-web-app-swift.com.war ${TOMCAT_HOME}/webapps
   echo "** Web application Swift successfully deployed. **"
 fi

 pid=`(ps x | grep "${TOMCAT_HOME}" | grep -v grep | cut -d ' ' -f 1)`
 if [ ! "${pid}" ]; then
  echo "Please start up your Tomcat server..."
  echo "To start the server, open a new terminal in ${TOMCAT_HOME}/bin and type sh catalina.sh run."
  echo
  return -1
 fi

cd ..
}

add_user() {
cd ${QSG}/QSG/bin/Setup-02
IS_name=$1
IS_pass=$2
scenario=$3
request_data="${scenario}/add-role.xml"
echo
echo "Creating a user named cameron..."

# The following command can be used to create a user.
curl -s -k --user ${IS_name}:${IS_pass} --data '{"schemas":[],"name":{"familyName":"Smith","givenName":"Cameron"},"userName":"cameron","password":"cameron123","emails":"cameron@gmail.com","addresses":{"country":"Canada"}}' --header "Content-Type:application/json" -o /dev/null https://localhost:9443/wso2/scim/Users

echo "** The user cameron was successfully created. **"
echo
echo "Creating a user named alex..."

# The following command can be used to create a user.
curl -s -k --user ${IS_name}:${IS_pass} --data '{"schemas":[],"name":{"familyName":"Miller","givenName":"Alex"},"userName":"alex","password":"alex123","emails":"alex@gmail.com","addresses":{"country":"Canada"}}' --header "Content-Type:application/json" -o /dev/null https://localhost:9443/wso2/scim/Users

echo "** The user alex was successfully created. **"
echo
echo "Creating a role named Manager..."

#The following command will add a role to the user.
curl -s -k -d @$request_data -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: text/xml" -H "SOAPAction: urn:addRole" -o /dev/null https://localhost:9443/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap11Endpoint/
echo "** The role Manager was successfully created. **"
echo
}

add_service_provider() {
cd ${QSG}/QSG/bin/Setup-02
sp_name=$1
scenario=$2
soap_action=$3
endpoint=$4
auth=$5
request_data="${scenario}/create-sp-${sp_name}.xml"
  
 if [ ! -d "$scenario" ]
  then
    echo "$scenario Directory not exists."
    return -1
  fi

  if [ ! -f "$request_data" ]
   then
    echo "$request_data File does not exists."
    return -1
  fi

echo "Creating Service Provider $sp_name..."
  
# Send the SOAP request to create the new SP.
curl -s -k -d @$request_data -H "Authorization: Basic ${auth}" -H "Content-Type: text/xml" -H "SOAPAction: ${soap_action}" -o /dev/null $endpoint	
echo "** Service Provider $sp_name successfully created. **"
echo
return 0;
}

delete_user() {
cd ${QSG}/QSG/bin/Setup-02
request_data1="2/delete-cameron.xml"
request_data2="2/delete-alex.xml"
request_data3="2/delete-role.xml"
echo
echo "Deleting the user named cameron..."

# Send the SOAP request to delete the user.
curl -s -k -d @$request_data1 -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: text/xml" -H "SOAPAction: urn:deleteUser" -o /dev/null https://localhost:9443/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap11Endpoint/

echo "** The user cameron was successfully deleted. **"
echo
echo "Deleting the user named alex..."

# Send the SOAP request to delete the user.
curl -s -k -d @$request_data2 -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: text/xml" -H "SOAPAction: urn:deleteUser" -o /dev/null https://localhost:9443/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap11Endpoint/

echo "** The user alex was successfully deleted. **"
echo
echo "Deleting the role named Manager..."

# Send the SOAP request to delete the role.
curl -s -k -d @2/delete-role.xml -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: text/xml" -H "SOAPAction: urn:deleteRole" -o /dev/null https://localhost:9443/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap11Endpoint/

echo "** The role Manager was successfully deleted. **"
echo
}

delete_sp() {
# cd ${QSG}/QSG/bin/Setup-02
sp_name=$1
scenario=$2
soap_action=$3
endpoint=$4
request_data="${scenario}/delete-sp-${sp_name}.xml"
  
 if [ ! -d "$scenario" ]
  then
    echo "$scenario Directory not exists."
    return -1
  fi

  if [ ! -f "$request_data" ]
   then
    echo "$request_data File does not exists."
    return -1
  fi
echo
echo "Deleting Service Provider $sp_name..."

# Send the SOAP request to delete a SP.
curl -s -k -d @$request_data -H "Authorization: Basic Y2FtZXJvbjpjYW1lcm9uMTIz" -H "Content-Type: text/xml" -H "SOAPAction: ${soap_action}" -o /dev/null $endpoint

echo "** Service Provider $sp_name successfully deleted. **"
return 0;
}

configure_saml() {
cd ${QSG}/QSG/bin/Setup-02
sp_name=$1
scenario=$2
soap_action=$3
endpoint=$4
auth=$5
request_data="${scenario}/sso-config-${sp_name}.xml"

 if [ ! -d "$scenario" ]
  then
    echo "$scenario Directory does not exists."
    return -1
  fi

  if [ ! -f "$request_data" ]
   then
    echo "$request_data File does not exists."
    return -1
  fi

echo "Configuring SAML2 web SSO for $sp_name..."

# Send the SOAP request for Confuring SAML2 web SSO.
curl -s -k -d @$request_data -H "Authorization: Basic ${auth}" -H "Content-Type: text/xml" -H "SOAPAction: ${soap_action}" -o /dev/null $endpoint  

echo "** Successfully configured SAML. **"
echo
return 0;
}

create_updateapp_xml() {
sp_name=$1
request_data="get-app-${sp_name}.xml"
auth=$2
cd ${QSG}/QSG/bin/Setup-02/2
 
 if [ ! -f "$request_data" ]
  then
    echo "$request_data File does not exists."
    return -1
  fi

 if [ -f "response_unformatted.xml" ] 
  then
   rm -r response_unformatted.xml
 fi
 
 if [ -f "response_formatted.xml" ]
  then
   rm -r response_formatted.xml  
 fi

touch response_unformatted.xml
touch response_formatted.xml

curl -k -d @$request_data -H "Authorization: Basic ${auth}" -H "Content-Type: text/xml" -H "SOAPAction: urn:getApplication" https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ > response_unformatted.xml

javac AppId.java
app_id=`java AppId`
echo "${app_id}"

 if [ -f "update-app-${sp_name}.xml" ]
  then 
   rm -r update-app-${sp_name}.xml
 fi
   
touch update-app-${sp_name}.xml
echo "<soapenv:Envelope xmlns:soapenv="\"http://schemas.xmlsoap.org/soap/envelope/"\" xmlns:xsd="\"http://org.apache.axis2/xsd"\" xmlns:xsd1="\"http://model.common.application.identity.carbon.wso2.org/xsd"\">
    <soapenv:Header/>
    <soapenv:Body>
        <xsd:updateApplication>
            <!--Optional:-->
            <xsd:serviceProvider>
                <!--Optional:-->
                <xsd1:applicationID>${app_id}</xsd1:applicationID>
                <!--Optional:-->
                <xsd1:applicationName>${sp_name}</xsd1:applicationName>
                <!--Optional:-->
                <xsd1:claimConfig>
                    <!--Optional:-->
                    <xsd1:alwaysSendMappedLocalSubjectId>false</xsd1:alwaysSendMappedLocalSubjectId>
                    <!--Optional:-->
                    <xsd1:localClaimDialect>true</xsd1:localClaimDialect>
                </xsd1:claimConfig>
                <!--Optional:-->
                <xsd1:description>sample service provider</xsd1:description>
                <!--Optional:-->
                <xsd1:inboundAuthenticationConfig>
                    <!--Zero or more repetitions:-->
                    <xsd1:inboundAuthenticationRequestConfigs>
                        <!--Optional:-->
                        <xsd1:inboundAuthKey>saml2-web-app-dispatch.com</xsd1:inboundAuthKey>
                        <!--Optional:-->
                        <xsd1:inboundAuthType>samlsso</xsd1:inboundAuthType>
                        <!--Zero or more repetitions:-->
                        <xsd1:properties>
                            <!--Optional:-->
                            <xsd1:name>attrConsumServiceIndex</xsd1:name>
                            <!--Optional:-->
                            <xsd1:value>1223160755</xsd1:value>
                        </xsd1:properties>
                    </xsd1:inboundAuthenticationRequestConfigs>
                </xsd1:inboundAuthenticationConfig>
                <!--Optional:-->
                <xsd1:inboundProvisioningConfig>
                    <!--Optional:-->
                    <xsd1:provisioningEnabled>false</xsd1:provisioningEnabled>
                    <!--Optional:-->
                    <xsd1:provisioningUserStore>PRIMARY</xsd1:provisioningUserStore>
                </xsd1:inboundProvisioningConfig>
                <!--Optional:-->
                <xsd1:localAndOutBoundAuthenticationConfig>
                    <!--Optional:-->
                    <xsd1:alwaysSendBackAuthenticatedListOfIdPs>false</xsd1:alwaysSendBackAuthenticatedListOfIdPs>
                    <!--Optional:-->
                    <xsd1:authenticationStepForAttributes></xsd1:authenticationStepForAttributes>
                    <!--Optional:-->
                    <xsd1:authenticationStepForSubject></xsd1:authenticationStepForSubject>
                    <xsd1:authenticationType>default</xsd1:authenticationType>
                    <!--Optional:-->
                    <xsd1:subjectClaimUri>http://wso2.org/claims/fullname</xsd1:subjectClaimUri>
                </xsd1:localAndOutBoundAuthenticationConfig>
                <!--Optional:-->
                <xsd1:outboundProvisioningConfig>
                    <!--Zero or more repetitions:-->
                    <xsd1:provisionByRoleList></xsd1:provisionByRoleList>
                </xsd1:outboundProvisioningConfig>
                <!--Optional:-->
                <xsd1:permissionAndRoleConfig></xsd1:permissionAndRoleConfig>
                <!--Optional:-->
                <xsd1:saasApp>false</xsd1:saasApp>
            </xsd:serviceProvider>
        </xsd:updateApplication>
    </soapenv:Body>
</soapenv:Envelope>" >> update-app-${sp_name}.xml 
}

update_application() {
sp_name=$1
scenario=$2
soap_action=$3
endpoint=$4
auth=$5
request_data="${scenario}/update-app-${sp_name}.xml"
cd ${QSG}/QSG/bin/Setup-02

 if [ ! -d "$scenario" ]
  then
    echo "$scenario Directory does not exists."
    return -1
  fi

  if [ ! -f "$request_data" ]
   then
    echo "$request_data File does not exists."
    return -1
  fi

echo
echo "Updating application ${sp_name}..."

# Send the SOAP request to Update the Application. 
curl -s -k -d @$request_data -H "Authorization: Basic ${auth}" -H "Content-Type: text/xml" -H "SOAPAction: ${soap_action}" -o /dev/null $endpoint 
echo "** Successfully updated the application ${sp_name}. **"
return 0;
}

echo "Please pick a scenario from the following."
echo "-----------------------------------------------------------------------------"
echo "|  Scenario 1 - Getting Started with WSO2 IS                                |"
echo "|  Scenario 2 - Configuring Single-Sign-On with SAML2                       |"
echo "|  Scenario 3 - Configuring Single-Sign-On with OIDC                        |"
echo "|  Scenario 4 - Configuring Multi-Factor Authentication                     |"
echo "|  Scenario 5 - Configuring Google as a Federated Authenticator             |"
echo "|  Scenario 6 - Setting up Self-Signup                                      |"
echo "|  Scenario 7 - Creating a workflow                                         |"  
echo "-----------------------------------------------------------------------------"
echo "Enter the scenario number you selected."

	read scenario
	case $scenario in
		1)
		echo "Getting Started with WSO2 IS"		
		;;
		
		2)
		configure_sso_saml2
		if [ "$?" -ne "0" ]; then
  		  echo "Sorry, we had a problem there!"
		 fi
		break ;;

		3)
		echo "Configuring Single-Sign-On with OIDC"
		break ;;
		
		4)
		echo "Configuring Multi-Factor Authentication"
		break ;;

		5)
		echo "Configuring Google as a Federated Authenticator"
		break ;;

		6)
		echo "Setting up Self-Signup"
		break ;;
		
		7)
		echo "Creating a workflow"
		break ;;

		*)
		echo "Sorry, that's not an option."
		;;
	esac	
echo

