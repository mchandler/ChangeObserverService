@IsTest
public class AdVic_ChangeObserverServiceTest {

    private static final String ACCOUNT_CHANGES_FIELD = 'Changed_Fields_List__c';

    @IsTest
    static void testTrackChanges(){
        Account account = new Account(Name = 'Test Account');
        insert account;

        List<Account> triggerNew = new List<Account>{account};
        Account oldAccount = account.clone(true);
        oldAccount.Name = 'Old Test Account';

        Map<Id, Account> oldMap = new Map<Id, Account>{
                account.Id => oldAccount
        };

        AdVic_ChangeObserverService.trackChanges(triggerNew, oldMap, ACCOUNT_CHANGES_FIELD);
        System.assertEquals('name', ((String) triggerNew.get(0).get(ACCOUNT_CHANGES_FIELD)).toLowerCase());
    }
}