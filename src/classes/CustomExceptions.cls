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

}
