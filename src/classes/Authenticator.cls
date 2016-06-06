/**
 * @author      :   srmaind
 * @date        :   6th June 2016
 * @description :   Contains logic to authenticate and with the insurance companies' orgs and store and return
 *                  access token from custom settings
 */
public with sharing class Authenticator {

    // @description Name for the Vehicle Insurance company
    public static String VEHICLE_INSURANCE_COMPANY = 'Ensurance';

    /**
    * @description Returns access token for the specified company name's Organization
    * @param    pCompanyName    Name of the Insurance company whose access token is being requested
    * @return   String          Access Token for the Organization
    */
    public String getAccessToken(String pCompanyName) {
        String accessToken;
        if (String.isNotBlank(pCompanyName)) {
            if (pCompanyName.equalsIgnoreCase(VEHICLE_INSURANCE_COMPANY)) {
                accessToken = getAccessTokenFromVehicleCompany();
            } else {
                throw new CustomExceptions.NullParametersException('Invalid company name in getAccessToken(). Look for company name constants in Authenticator class');
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
    private String getAccessTokenFromVehicleCompany() {
        return null;
    }

}
