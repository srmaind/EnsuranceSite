public with sharing class AuthenticationFlows {

    private static final String USERNAME = 'srmaind@ensurance.com';
    private static final String PASSWORD = 'ensurancepJZ8DJ8V44te11djXBKN3Yjms';
    private static final String AUTHORIZATION_URL = 'https://login.salesforce.com/services/oauth2/authorize';
    private static final String TOKEN_URL = 'https://login.salesforce.com/services/oauth2/token';
    private static final String CONSUMER_KEY =
                                '3MVG9ZL0ppGP5UrCOuzqJLNrHkxfB_d4yMkP3W1CvxddYE_ymHygNF8oQKXDmY_tu08IVBPeA99oLlskJTrz5';
    private static final String CONSUMER_SECRET ='3859079004436199361';
    private static final String REDIRECT_URI = 'https://ap2.salesforce.com/apex/Authentication';
    public static String SERVER_URL {get; set;}
    public static String SESSION_ID {get; set;}
    public Map<String, Object> mapParams {get; set;}
    public String strMapParams {get; set;}

    public AuthenticationFlows() {
        mapParams = new Map<String, Object>();
    }

    public PageReference pageaction() {
        /*if (String.isNotBlank(strMapParams)) {
            try {
                mapParams = (Map<String, Object>) Json.deserializeUntyped(strMapParams);
            } catch (JSONException jsonExcp) {
                System.debug('jsonExcp while deserializing "parameters" object = ' + jsonExcp);
            }
        }
        String code = (String) mapParams.get('code');
        SERVER_URL = (String) mapParams.get('instance_url');
        SESSION_ID = (String) mapParams.get('access_token');
        System.debug('URL parameters = ' + mapParams);
        if (String.isNotBlank(code)) {
            getAccessTokenFromCode(code);
        } else if (String.isNotBlank(SERVER_URL) && String.isNotBlank(SESSION_ID)) {
            callApi();
        } else {
            return userAgentAuthenticationFlow();
        }*/
        usernamePasswordAuthenticationFlow();
        return null;
    }

    public static void usernamePasswordAuthenticationFlow() {
        HttpRequest request= new HttpRequest();
        String endPointUrl = 'https://login.salesforce.com/services/oauth2/token'
                            + '?grant_type=password&client_id=' + EncodingUtil.urlEncode(CONSUMER_KEY, 'UTF-8')
                            + '&client_secret=' + EncodingUtil.urlEncode(CONSUMER_SECRET, 'UTF-8')
                            + '&username=' + EncodingUtil.urlEncode(USERNAME, 'UTF-8')
                            + '&password=' + EncodingUtil.urlEncode(PASSWORD, 'UTF-8');
        request.setEndpoint(endPointUrl);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        try {
            HttpResponse response = new Http().send(request);
            System.debug('response = ' + response);
            System.debug('response body = ' + response.getBody());
            AccessTokenWrapper wrapper;
            try {
                wrapper = (AccessTokenWrapper)Json.deserialize(response.getBody(), AccessTokenWrapper.class);
            } catch (JSONException jsonExcp) {
                System.debug('JSONException occurred while deserializing access token : ' + jsonExcp);
            }
            System.debug('accessTokenWrapper = ' + wrapper);
            if (wrapper != null) {
                SERVER_URL = wrapper.instance_url;
                SESSION_ID = wrapper.access_token;
                callApi();
            }
        } catch(Exception excp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, excp.getMessage()));
        }
    }

    public static PageReference userAgentAuthenticationFlow() {
        return new PageReference(AUTHORIZATION_URL
                            + '?response_type=token&client_id=' + EncodingUtil.urlEncode(CONSUMER_KEY, 'UTF-8')
                            + '&redirect_uri=' + EncodingUtil.urlEncode(REDIRECT_URI, 'UTF-8'));
    }

    public static PageReference webServerAuthenticationFlow() {
        return new PageReference(AUTHORIZATION_URL
                            + '?response_type=code&client_id=' + EncodingUtil.urlEncode(CONSUMER_KEY, 'UTF-8')
                            + '&redirect_uri=' + EncodingUtil.urlEncode(REDIRECT_URI, 'UTF-8'));
    }

    public void getAccessTokenFromCode(String code) {
        HttpRequest request= new HttpRequest();
        String endPointUrl = TOKEN_URL
                            + '?grant_type=authorization_code&client_id=' + CONSUMER_KEY
                            + '&client_secret=' + CONSUMER_SECRET
                            + '&redirect_uri=' + EncodingUtil.urlEncode(REDIRECT_URI, 'UTF-8')
                            + '&code=' + code;
        request.setEndpoint(endPointUrl);
        request.setMethod('POST');
        // request.setHeader('Accept', 'application/json');
        try {
            HttpResponse response = new Http().send(request);
            System.debug('response = ' + response);
            System.debug('response body = ' + response.getBody());
            AccessTokenWrapper wrapper;
            try {
                wrapper = (AccessTokenWrapper)Json.deserialize(response.getBody(), AccessTokenWrapper.class);
            } catch (JSONException jsonExcp) {
                System.debug('JSONException occurred while deserializing access token : ' + jsonExcp);
            }
            System.debug('accessTokenWrapper = ' + wrapper);
            if (wrapper != null) {
                SERVER_URL = wrapper.instance_url;
                SESSION_ID = wrapper.access_token;
                callApi();
            }
        } catch(Exception excp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, excp.getMessage()));
        }
    }

    private static void authenticateFromSoapApi() {
        HttpRequest request= new HttpRequest();
        request.setEndpoint('https://login.salesforce.com/services/Soap/u/22.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + USERNAME + '</username><password>' + PASSWORD + '</password></login></Body></Envelope>');
        try {
            Dom.XmlNode resultElmt = (new Http()).send(request).getBodyDocument().getRootElement()
              .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
              .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
              .getChildElement('result', 'urn:partner.soap.sforce.com');
            System.debug('resultElmt = ' + resultElmt);
            SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com') .getText().split('/services')[0];
            SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com') .getText();
            System.debug('SERVER_URL = ' + SERVER_URL);
            System.debug('SESSION_ID = ' + SESSION_ID);

            // callApi();
        } catch(Exception excp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, excp.getMessage()));
        }
    }

    private static void callApi() {
        HttpRequest request= new HttpRequest();
        request.setEndpoint(SERVER_URL + '/services/apexrest/testrest');
        System.debug('request endpoint URL = ' + request.getEndpoint());
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + SESSION_ID);
        try {
            HttpResponse response = new Http().send(request);
            System.debug('Response = ' + response);
            System.debug('Response StatusCode = ' + response.getStatusCode());
            System.debug('Response Body = ' + response.getBody());
            ApexPages.addmessage(new ApexPages.message(
                ApexPages.severity.INFO, response.toString() + response.getBody()
            ));
        } catch(Exception excp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, excp.getMessage()));
        }
    }

    private static void callApi(String pAccessToken) {
        HttpRequest request= new HttpRequest();
        request.setEndpoint(SERVER_URL + '/services/apexrest/testrest');
        System.debug('request endpoint URL = ' + request.getEndpoint());
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + pAccessToken);
        try {
            HttpResponse response = new Http().send(request);
            System.debug('Response = ' + response);
            System.debug('Response StatusCode = ' + response.getStatusCode());
            System.debug('Response Body = ' + response.getBody());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, response.toString()));
        } catch(Exception excp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, excp.getMessage()));
        }
    }

    public class AccessTokenWrapper {
        public String access_token;
        public String refresh_token;
        public String signature;
        public String scope;
        public String id_token;
        public String instance_url;
        public String id;
        public String token_type;
        public String issued_at;
    }

}