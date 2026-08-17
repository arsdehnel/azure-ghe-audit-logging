public with sharing class SearchController {
    // PMD ApexSOQLInjection: user input concatenated directly into a dynamic query
    public static List<Account> searchByName(String name) {
        return Database.query('SELECT Id, Name FROM Account WHERE Name LIKE \'%' + name + '%\'');
    }

    // PMD ApexCRUDViolation: no FLS/CRUD check before DML
    public static void createAccount(String name) {
        Account a = new Account(Name = name);
        insert a;
    }
}
