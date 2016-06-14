/**
 * @author      :   srmaind
 * @date        :   14th June 2016
 * @description :   Contains Wrapper Classes Data Transfer Objects
 */
public class Dto {

    /**
     * @description :   DTO for successful access token callout response
     */
    public class AccessTokenResult {
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

    /**
     * @description :   DTO for Access Token Error message(s)
     */
    public class AccessTokenError {
        public String message;
        public String errorCode;
      }

}
