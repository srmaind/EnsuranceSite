/**
 * @author      :   srmaind
 * @date        :   6th June 2016
 * @description :   Contains logic to authenticate and with the insurance companies' orgs and store and return
 *                  access token from custom settings
 */
public with sharing class Authenticator {

    // @description Name for the Vehicle Insurance company
    public static String VEHICLE_INSURANCE_COMPANY = 'Ensurance';
    // @description Endpoint URL for HTTP request for getting new Access Token
    private static final String TOKEN_URL = 'https://login.salesforce.com/services/oauth2/token';

    /**
    * @description Returns access token for the specified company name's Organization
    * @param    companyName    Name of the Insurance company whose access token is being requested
    * @return   String          Access Token for the Organization
    */
    public static String getAccessToken(String companyName) {
        String accessToken;
        if (String.isNotBlank(companyName)) {
            if (companyName.equalsIgnoreCase(VEHICLE_INSURANCE_COMPANY)) {
                accessToken = getAccessTokenFromVehicleCompany();
            } else {
                throw new CustomExceptions.InvalidParametersException('Invalid company name in getAccessToken(). Look for company name constants in Authenticator class');
            }
        } else {
            throw new CustomExceptions.NullParametersException('Null Parameter sent for company name in getAccessToken()');
        }
        return accessToken;
    }

    /**
    * @description  Returns access token for the Vehicle Insurance Company's Organization
    * @return       String Access Token for the Organization
    */
    private static String getAccessTokenFromVehicleCompany() {
        String accessToken;
        InsuranceAuth__c authorizationDetails = getAuthorizationDetailsForCompany(VEHICLE_INSURANCE_COMPANY);
        if (authorizationDetails != null) {
            if (String.isBlank(authorizationDetails.AccessToken__c)) {
                authorizationDetails = getNewAccessToken(authorizationDetails);
            }
            if (authorizationDetails != null) {
                accessToken = authorizationDetails.AccessToken__c;
            }
        } else {
            throw new CustomExceptions.AuthorizationNotFoundException('Unable to retrieve Authorization details from Custom Settings in getAccessTokenFromVehicleCompany()');
        }
        return accessToken;
    }

    /**
     * @description Returns the instance of InsuranceAuth__c custom settings for the requested Insurance company
     * @return      InsuranceAuth__c Custom settings instance
     */
    private static InsuranceAuth__c getAuthorizationDetailsForCompany(String companyName) {
        InsuranceAuth__c authorizationDetails;
        if (String.isNotBlank(companyName)) {
            authorizationDetails = InsuranceAuth__c.getInstance(companyName);
        } else {
            throw new CustomExceptions.NullParametersException('Null Parameter sent for company name in getAuthorizationDetailsForCompany()');
        }
        return authorizationDetails;
    }

    /**
     * @description Fetches new Access Token from the given authorization details
     * @return      InsuranceAuth__c Custom settings instance with new Access Token
     */
    private static InsuranceAuth__c getNewAccessToken(InsuranceAuth__c authDetails) {
        if (authDetails != null) {
            HttpRequest request= new HttpRequest();
            String PASSWORD;
            if (String.isNotBlank(authDetails.SecurityToken__c)) {
                PASSWORD = authDetails.Password__c + authDetails.SecurityToken__c;
            }
            String endPointUrl = TOKEN_URL +
                            + '?grant_type=password'
                            + '&client_id=' + EncodingUtil.urlEncode(authDetails.ConsumerKey__c, 'UTF-8')
                            + '&client_secret=' + EncodingUtil.urlEncode(authDetails.ConsumerSecret__c, 'UTF-8')
                            + '&username=' + EncodingUtil.urlEncode(authDetails.Username__c, 'UTF-8')
                            + '&password=' + EncodingUtil.urlEncode(authDetails.Password__c, 'UTF-8');

            request.setEndpoint(endPointUrl);
            request.setMethod('POST');
            request.setHeader('Accept', 'application/json');

            HttpResponse response = new Http().send(request);
            String accessTokenResponse = response.getBody();

            Dto.AccessTokenResult accessTokenResult = (Dto.AccessTokenResult)Json.deserialize(accessTokenResponse, Dto.AccessTokenResult.class);

            if (accessTokenResult != null) {
                authDetails.InstanceUrl__c = accessTokenResult.instance_url;
                authDetails.AccessToken__c = accessTokenResult.access_token;
                updateAuthorizationDetails(authDetails.Name, accessTokenResponse);
            }
            return authDetails;
        } else {
            throw new CustomExceptions.NullParametersException('Null Parameter sent for company name in getNewAccessToken()');
        }
        return null;
    }

    /**
     * @description Async method for updating Authorization custom settings for optimizing authentication process time
     */
    @future
    private static void updateAuthorizationDetails(String authDetailsName, String accessTokenResponse) {
        if (String.isNotBlank(authDetailsName) && String.isNotBlank(accessTokenResponse)) {
            InsuranceAuth__c authDetails = InsuranceAuth__c.getInstance(authDetailsName);
            if (authDetails != null) {
                Dto.AccessTokenResult accessTokenResult = (Dto.AccessTokenResult)Json.deserialize(accessTokenResponse, Dto.AccessTokenResult.class);

                if (accessTokenResult != null) {
                    authDetails.InstanceUrl__c = accessTokenResult.instance_url;
                    authDetails.AccessToken__c = accessTokenResult.access_token;
                    updateAuthorizationDetails(authDetails.Name, accessTokenResponse);
                }

            } else {
                // Can log this exception to a Custom Object
                throw new CustomExceptions.InvalidParametersException('Invalid authDetailsName/company name in updateAuthorizationDetails(). Look for company name constants in Authenticator class');
            }
        } else {
            throw new CustomExceptions.NullParametersException('Null Parameter(s) sent in updateAuthorizationDetails()');
        }
    }

}
