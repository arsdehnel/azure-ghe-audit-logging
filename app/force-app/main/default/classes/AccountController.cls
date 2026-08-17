/**
 * @description Read-only account queries with enforced sharing and FLS.
 */
public with sharing class AccountController {
    /**
     * @description Returns up to 200 accounts ordered by name.
     * @return List of Account records
     */
    public static List<Account> getAccounts() {
        return [SELECT Id, Name FROM Account WITH SECURITY_ENFORCED ORDER BY Name LIMIT 200];
    }

    /**
     * @description Returns a single account by Id.
     * @param accountId The Id of the account to retrieve
     * @return The matching Account record
     */
    public static Account getById(Id accountId) {
        return [SELECT Id, Name FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED LIMIT 1];
    }
}
