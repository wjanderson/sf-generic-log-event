/**
 * @File Name          : accc_MetadataLogEventQueueableTest.cls
 * @Description        : Test accc_MetadataLogEventQueueable
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/26/2019    Bill Anderson      Initial Version
 **/

@isTest
private class accc_MetadataLogEventQueueableTest {

    static final String THE_DOMAIN = 'Contact';
    static final accc_MetadataLogEventProcessor THE_PROCESSOR = new accc_MetadataLogEventProcessor(THE_DOMAIN, accc_ApexConstants.TEST_CATEGORY);

    @isTest
    static void testctorWithBadProcessor(){
        // assign
        List<SObject> clist = getContactList();
        // act
        accc_MetadataLogEventQueueable queue = new accc_MetadataLogEventQueueable(null,clist);
        Test.startTest();
        queue.execute();
        Test.stopTest();
        // assert
        system.assertEquals(true, queue.theProcessor == null );
        system.assertEquals(true, queue.entries != null );
        system.assertEquals(true, accc_ApexUtilities.containsInTestLog(accc_MetadataLogEventQueueable.PROCESS_CALLED) );


    }
    @isTest
    static void testctorWithBadList(){
        // assign
        List<SObject> clist = getContactList();
        // act
        accc_MetadataLogEventQueueable queue = new accc_MetadataLogEventQueueable(THE_PROCESSOR,null);
        Test.startTest();
        queue.execute();
        Test.stopTest();
        // assert
        system.assertEquals(true, queue.theProcessor != null );
        system.assertEquals(true, queue.entries == null );
        // assert
        system.assertEquals(false, accc_ApexUtilities.containsInTestLog(accc_MetadataLogEventQueueable.PROCESS_CALLED) );
        system.assertEquals(false, accc_ApexUtilities.containsInTestLog(accc_MetadataLogEventQueueable.PROCESSOR_CALLED) );

    }

    @isTest
    static void testprocessWithBadList(){

        // act
        accc_MetadataLogEventQueueable queue = new accc_MetadataLogEventQueueable(THE_PROCESSOR,null);
        Test.startTest();
        queue.execute();
        Test.stopTest();
        // assert
        system.assertEquals(false, accc_ApexUtilities.containsInTestLog(accc_MetadataLogEventQueueable.PROCESS_CALLED) );
        system.assertEquals(false, accc_ApexUtilities.containsInTestLog(accc_MetadataLogEventQueueable.PROCESSOR_CALLED) );

    }
    @isTest
    static void testprocessWithGoodData(){
        // assign
        List<SObject> clist = getContactList();
        // act
        accc_MetadataLogEventQueueable queue = new accc_MetadataLogEventQueueable(THE_PROCESSOR,clist);
        Test.startTest();
        queue.execute();
        Test.stopTest();
        // assert
        system.assertEquals(true, accc_ApexUtilities.containsInTestLog(accc_MetadataLogEventQueueable.PROCESS_CALLED) );
        system.assertEquals(true, accc_ApexUtilities.containsInTestLog(accc_MetadataLogEventQueueable.PROCESSOR_CALLED) );

    }

    static List<Contact> getContactList() {
        return [select id,Birthdate, AssistantName, Email, DoNotCall,HomePhone from Contact];
    }

    @TestSetup
    static void makeData(){
        ACCCTestUtility.getNewContact();
        ACCCTestUtility.getNewContact();
        ACCCTestUtility.getNewContact();
    }
}// end of accc_MetadataLogEventQueueableTest