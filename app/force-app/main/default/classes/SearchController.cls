/**
 * @description Search utilities -- intentionally contains security violations for demo purposes.
 */
public with sharing class SearchController {
    /**
     * @description Searches accounts by name -- vulnerable to SOQL injection.
     * @param name Unescaped user input concatenated directly into a dynamic query
     * @return List of matching Account records
     */
    public static List<Account> searchByName(String name) {
        // PMD ApexSOQLInjection: user input concatenated directly into a dynamic query
        return Database.query('SELECT Id, Name FROM Account WHERE Name LIKE \'%' + name + '%\'');
    }

    /**
     * @description Creates an account without a CRUD check.
     * @param name Name for the new account
     */
    public static void createAccount(String name) {
        // PMD ApexCRUDViolation: no CRUD/FLS check before DML
        Account a = new Account(Name = name);
        insert a;
    }
}
