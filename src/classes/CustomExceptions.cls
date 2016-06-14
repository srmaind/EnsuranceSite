/**
 * @author      :   srmaind
 * @date        :   6th June 2016
 * @description :   Contains Custom Exception Classes
 */
public class CustomExceptions {

    // @description Throw when null parameters are passed to the current function
    public class NullParametersException extends Exception {}

    // @description Throw when invalid parameters are passed to the current function
    public class InvalidParametersException extends Exception {}

    // @description Throw when Authorization details are not found in the Custom Settings
    public class AuthorizationNotFoundException extends Exception {}

    // @description Throw when any general uncategorized exception occurs
    public class CustomException extends Exception {}

}
