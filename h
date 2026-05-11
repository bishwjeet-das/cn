import java.util.Scanner;


class Factorial {

    // Private instance variable
    private long[] factorialArray;

    // Default constructor
    public Factorial() {

        factorialArray = new long[21];

        factorialArray[0] = 1;

        // Precompute factorial values
        for (int i = 1; i < factorialArray.length; i++) {

            factorialArray[i] = i * factorialArray[i - 1];
        }
    }

    
    public Factorial(int size) {

        factorialArray = new long[size];

        factorialArray[0] = 1;

        for (int i = 1; i < factorialArray.length; i++) {

            factorialArray[i] = i * factorialArray[i - 1];
        }
    }

    
    public long[] getFactorialArray() {

        return factorialArray;
    }

    
    public void setFactorialArray(long[] factorialArray) {

        this.factorialArray = factorialArray;
    }

    
    public long computeFactorial(int x) {

        // Check negative value
        if (x < 0) {

            throw new IllegalArgumentException(
                    "value of x must be positive");
        }

        
        if (x >= factorialArray.length) {

            throw new IllegalArgumentException(
                    "result will overflow.");
        }

        // Return factorial value
        return factorialArray[x];
    }
}


public class Fact {

    public static void main(String[] args) {

        Scanner scanner = new Scanner(System.in);

        
        Factorial factorialObject = new Factorial();

        try {

            System.out.print("Enter a number: ");
            int number = scanner.nextInt();

            long result =
                    factorialObject.computeFactorial(number);

            System.out.println(
                    "Factorial of " + number + " = " + result);

        }

        
        catch (IllegalArgumentException exceptionObject) {

            System.out.println(
                    "Exception: " + exceptionObject.getMessage());
        }

        
        catch (Exception exceptionObject) {

            System.out.println("Invalid input.");
        }

        finally {

            scanner.close();
        }
    }
}



import java.util.Scanner;


class EmailValidator {

    
    private String emailId;

    
    public EmailValidator() {

        emailId = "";
    }

    
    public EmailValidator(String emailId) {

        this.emailId = emailId;
    }

    
    public String getEmailId() {

        return emailId;
    }

    
    public void setEmailId(String emailId) {

        this.emailId = emailId;
    }

    
    public void validateEmail(String email)
            throws IllegalArgumentException {

        // Basic email validation
        if (!(email.contains("@") &&
                email.contains(".") &&
                email.indexOf("@") < email.lastIndexOf("."))) {

            // Throw exception manually
            throw new IllegalArgumentException(
                    "Invalid Email ID");
        }

        System.out.println("Valid Email ID");
    }
}


public class EmailValidationDemo {

    public static void main(String[] args) {

        Scanner scanner = new Scanner(System.in);

        EmailValidator validatorObject =
                new EmailValidator();

        try {

            System.out.print("Enter Email ID: ");
            String email = scanner.nextLine();

            validatorObject.validateEmail(email);
        }

        
        catch (IllegalArgumentException exceptionObject) {

            System.out.println(
                    "Exception: "
                            + exceptionObject.getMessage());
        }

        finally {

            scanner.close();
        }
    }
}
