public with sharing class AccountController {
    public static List<Account> getAccounts() {
        return [SELECT Id, Name FROM Account WITH SECURITY_ENFORCED];
    }

    public static Account getById(Id accountId) {
        return [SELECT Id, Name FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED LIMIT 1];
    }
}
